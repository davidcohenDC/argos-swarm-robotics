#!/usr/bin/env bash
# Runs one lab (or all of them) without the GUI and prints what the controller
# logs when the experiment ends.
#
#   scripts/run.sh 04-swarm-aggregation          3000 ticks, seed 1
#   scripts/run.sh 02-subsumption 600 7          600 ticks, seed 7
#   scripts/run.sh all 300                       every lab, 300 ticks
#
# The .argos files are not modified: a copy with the experiment length,
# the seed and an empty <visualization/> is written next to them and removed
# at the end. Lab 4 reads ALPHA, BETA, S, W, ... from the environment.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
lab=${1:?usage: scripts/run.sh <lab-folder|all> [ticks] [seed]}
ticks=${2:-3000}
seed=${3:-1}

if [ "$lab" = all ]; then
    for d in "$root"/0*/; do
        "$0" "$(basename "$d")" "$ticks" "$seed"
        echo
    done
    exit 0
fi

cd "$root/$lab"
config=$(ls ./*.argos)             # each lab has exactly one .argos at its top level
run_config=$(mktemp ./.run-XXXX.argos)
trap 'rm -f "$run_config"' EXIT

xmlstarlet ed \
    -u '/argos-configuration/framework/experiment/@length' -v "$ticks" \
    -d '/argos-configuration/framework/experiment/@random_seed' \
    -i '/argos-configuration/framework/experiment' -t attr -n random_seed -v "$seed" \
    -d '/argos-configuration/visualization/*' \
    "$config" > "$run_config"

echo "== $lab: $config, $ticks ticks, seed $seed"
output=$(argos3 -n -c "$run_config" 2>&1) || { echo "$output"; exit 1; }

# Labs 2 and 3 log "Distance: <m>" once, lab 4 logs "Average Neighbor Distance: <cm>"
# once per robot; lab 1 logs nothing at the end.
metrics=$(echo "$output" | grep -oE 'Distance: [0-9.]+' | awk '{ print $2 }' || true)
if [ -z "$metrics" ]; then
    echo "finished, no end-of-run metric in this lab"
else
    echo "$metrics" | awk '{ s += $1; n++ } END { if (n == 1) printf "%s\n", $1; else printf "%.2f (mean of %d robots)\n", s / n, n }'
fi
