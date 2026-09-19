#!/usr/bin/env bash
# Records one lab into docs/<lab>.gif with ARGoS' own frame grabbing, under Xvfb.
#
#   scripts/record.sh 04-swarm-aggregation 3000      3000 ticks
#   scripts/record.sh all
#
# As in run.sh the 2024 .argos files stay as they are: the copy gets the
# length, a fixed seed, autoplay, a top-down camera and the frame_grabbing
# block. ARGoS redraws ten times per tick; headless_frame_rate keeps about
# 600 frames and ffmpeg 120 of them, so every GIF lasts 12 seconds at 10 fps.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
lab=${1:?usage: scripts/record.sh <lab-folder|all> [ticks] [frames-in-gif]}

if [ "$lab" = all ]; then
    "$0" 01-reactive-controller 600
    "$0" 02-subsumption 600
    "$0" 03-motor-schemas 600
    "$0" 04-swarm-aggregation 3000
    exit 0
fi

ticks=${2:-600}
wanted=${3:-120}
seed=${SEED:-1}

cd "$root/$lab"
config=$(ls ./*.argos)
frames=$(mktemp -d ./.frames-XXXX)
run_config=$(mktemp ./.record-XXXX.argos)
trap 'rm -rf "$frames" "$run_config"' EXIT

grab_every=$(( ticks * 10 / 600 )); [ "$grab_every" -ge 1 ] || grab_every=1

# Camera straight above the arena centre, high enough to see all of it.
arena=$(xmlstarlet sel -t -v '/argos-configuration/arena/@size' "$config")
height=$(echo "$arena" | awk -F'[, ]+' '{ m = ($1 > $2) ? $1 : $2; printf "%.2f", m * 0.8 }')

xmlstarlet ed \
    -u '/argos-configuration/framework/experiment/@length' -v "$ticks" \
    -d '/argos-configuration/framework/experiment/@random_seed' \
    -i '/argos-configuration/framework/experiment' -t attr -n random_seed -v "$seed" \
    -i '/argos-configuration/visualization/qt-opengl' -t attr -n autoplay -v true \
    -d '/argos-configuration/visualization/qt-opengl/camera' \
    -s '/argos-configuration/visualization/qt-opengl' -t elem -n camera \
    -s '/argos-configuration/visualization/qt-opengl/camera' -t elem -n placements \
    -s '/argos-configuration/visualization/qt-opengl/camera/placements' -t elem -n placement \
    -i '/argos-configuration/visualization/qt-opengl/camera/placements/placement' -t attr -n index -v 0 \
    -i '/argos-configuration/visualization/qt-opengl/camera/placements/placement' -t attr -n position -v "0.001,0,$height" \
    -i '/argos-configuration/visualization/qt-opengl/camera/placements/placement' -t attr -n look_at -v "0,0,0" \
    -i '/argos-configuration/visualization/qt-opengl/camera/placements/placement' -t attr -n lens_focal_length -v 20 \
    -s '/argos-configuration/visualization/qt-opengl' -t elem -n frame_grabbing \
    -i '/argos-configuration/visualization/qt-opengl/frame_grabbing' -t attr -n directory -v "$frames" \
    -i '/argos-configuration/visualization/qt-opengl/frame_grabbing' -t attr -n base_name -v frame_ \
    -i '/argos-configuration/visualization/qt-opengl/frame_grabbing' -t attr -n format -v png \
    -i '/argos-configuration/visualization/qt-opengl/frame_grabbing' -t attr -n quality -v 100 \
    -i '/argos-configuration/visualization/qt-opengl/frame_grabbing' -t attr -n headless_grabbing -v true \
    -i '/argos-configuration/visualization/qt-opengl/frame_grabbing' -t attr -n headless_frame_size -v 640x640 \
    -i '/argos-configuration/visualization/qt-opengl/frame_grabbing' -t attr -n headless_frame_rate -v "$grab_every" \
    "$config" > "$run_config"

echo "== $lab: $ticks ticks, seed $seed"
xvfb-run -a -s "-screen 0 800x800x24" argos3 -n -c "$run_config" > /dev/null 2>&1 \
    || { echo "argos3 failed; rerun without the redirect to see why"; exit 1; }

count=$(ls "$frames" | wc -l)
[ "$count" -gt 0 ] || { echo "no frames were written"; exit 1; }

step=$(( (count + wanted - 1) / wanted ))
mkdir -p "$root/docs"
ffmpeg -loglevel error -y -pattern_type glob -i "$frames/frame_*.png" \
    -vf "select=not(mod(n\,$step)),setpts=N/10/TB,crop=in_h:in_h,scale=480:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=64:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=3:diff_mode=rectangle" \
    -r 10 -loop 0 "$root/docs/$lab.gif"

echo "$count frames, kept 1 in $step -> docs/$lab.gif ($(du -h "$root/docs/$lab.gif" | cut -f1))"
