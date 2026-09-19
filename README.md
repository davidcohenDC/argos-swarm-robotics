# ARGoS swarm robotics

[![Build](https://github.com/davidcohenDC/argos-swarm-robotics/actions/workflows/build.yml/badge.svg)](https://github.com/davidcohenDC/argos-swarm-robotics/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/davidcohenDC/argos-swarm-robotics)](https://github.com/davidcohenDC/argos-swarm-robotics/releases/latest)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Four foot-bot controllers written in Lua for the [ARGoS](https://www.argos-sim.info/)
simulator, from the Intelligent Robotic Systems course at the University of
Bologna. In the first three a single robot has to reach a light without
hitting anything, and each lab solves it with a different control
architecture. In the fourth, fifty robots have to gather in one place using
only what they can sense and hear around them. Every lab comes with its report.

The GIFs are recorded from ARGoS, see [Run it](#run-it).

<table>
  <tr>
    <td align="center"><img src="docs/01-reactive-controller.gif" alt="Lab 1: one robot reaching the light, priority between behaviours fixed in code" width="360"><br><sub>1 · reactive controller</sub></td>
    <td align="center"><img src="docs/02-subsumption.gif" alt="Lab 2: the same task with a subsumption architecture" width="360"><br><sub>2 · subsumption</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/03-motor-schemas.gif" alt="Lab 3: the same task with motor schemas and potential fields" width="360"><br><sub>3 · motor schemas</sub></td>
    <td align="center"><img src="docs/04-swarm-aggregation.gif" alt="Lab 4: fifty robots gathering, red LEDs are the stopped ones" width="360"><br><sub>4 · swarm aggregation</sub></td>
  </tr>
</table>

## What they do

The robot has 24 proximity sensors, 24 light sensors and two wheels. In lab 4
it also has a range-and-bearing radio: 10-byte messages, line of sight only.
There is no map and no global position.

- **[01-reactive-controller](01-reactive-controller)**: obstacle avoidance,
  phototaxis and random walk, with the priority written in `step()`. The first
  behaviour that has something to do takes the wheels;
- **[02-subsumption](02-subsumption)**: the same behaviours as layers of a
  subsumption architecture. Each layer is a module with `condition()` and
  `execute()`, kept in a priority queue. The highest layer whose condition
  holds wins. Wandering is probabilistic here, not step-counted;
- **[03-motor-schemas](03-motor-schemas)**: no arbitration. Attraction to the
  light, repulsion from obstacles, noise and repulsion from the positions the
  robot visited recently are vectors, summed with weights and turned into wheel
  speeds. A small uniform field keeps the robot moving when the other forces
  are weak, and a light threshold switches between an aggressive mix and an
  exploratory one that follows walls. Weights are in `config.lua`;
- **[04-swarm-aggregation](04-swarm-aggregation)**: every robot is a WALK/STOP
  automaton on top of the lab 2 stack. It broadcasts its state, counts the
  stopped neighbours `N` it hears, stops with probability `min(PsMax, S + α·N)`
  and starts again with probability `max(PwMin, W − β·N)`. LEDs are green when
  walking, yellow when avoiding something, red when stopped. Parameters come
  from the environment, with defaults in `hyperparameters.lua`.

Labs 2 to 4 have a `test/` folder with the script that runs the experiments
headless and the Python that draws the plots: 500 runs for lab 2, 300 runs and
a Mann–Whitney test on the seeds for lab 3, a sweep of 81 combinations of α,
β, S and W for lab 4. The best set gives 27 cm of mean distance between
neighbours, the worst ones stay above 50 cm. Small changes in the parameters
move the result a lot, and the report says so.

## Run it

You need Docker. Then:

```sh
git clone https://github.com/davidcohenDC/argos-swarm-robotics.git
cd argos-swarm-robotics
docker compose run --rm argos scripts/run.sh 04-swarm-aggregation
```

Compose pulls the image from GitHub Packages, ARGoS included; if it cannot,
it builds it from source, which takes a few minutes, once. Dependencies are
pinned and not updated. The command runs the lab for 3000 ticks without a window and
prints what the controller logs at the end: the final distance to the light in
labs 2 and 3, the mean distance between neighbours in lab 4.
`scripts/run.sh all 300` runs every lab for 300 ticks, which is what the CI
does. Lab 4 reads its parameters from the environment:

```sh
ALPHA=0.05 docker compose run --rm argos scripts/run.sh 04-swarm-aggregation
```

To watch a lab, install [ARGoS 3](https://www.argos-sim.info/core.php) and
open its arena:

```sh
cd 02-subsumption
argos3 -c test-subs.argos
```

The GIFs come from `scripts/record.sh <lab>`. It runs the same arena under
Xvfb with the frame grabbing of ARGoS and passes the frames to ffmpeg. Neither
script changes the `.argos` files: both write a temporary copy next to them
with the length, the seed, the camera and no window.

Prefer not to clone? Each
[release](https://github.com/davidcohenDC/argos-swarm-robotics/releases/latest)
ships a zip with everything, plus the ARGoS source the image is built from.

## How it is organised

```
01-reactive-controller/   task_one.lua, utilities.lua, proximity.lua, task_one.argos
02-subsumption/           task_two.lua, lib/behaviours/, lib/priority_queue.lua, test-subs.argos, test/
03-motor-schemas/         controller-motor_schemas.lua, lib/schemas/, config.lua, motor_schemas.argos, test/
04-swarm-aggregation/     aggregation.lua, lib/behaviours/, lib/rab.lua, hyperparameters.lua, aggregation.argos, test/
scripts/                  run.sh (headless run), record.sh (GIFs)
Dockerfile, compose.yaml  ARGoS built from source at a pinned commit, plus Xvfb and ffmpeg; published to ghcr.io
```

ARGoS has no package for current Ubuntu releases, so the image builds it.

## License

[MIT](LICENSE) © 2024 David Cohen
