# Overview
This project involves implementing a subsumption architecture for a footbot robot to combine multiple behaviors: 
phototaxy, obstacle-avoidance, and wander. The robot navigates towards a light source while avoiding collisions with obstacles.

## Tasks
- **Phototaxy:** Highest priority; avoids collisions using proximity sensors.
- **Obstacle Avoidance:** Medium priority; moves towards the light source using light sensors.
- **Wander:** Lowest priority; executes when no light or obstacles are detected.

## Evaluation Criteria

- **Time to Reach the Light:** The time taken for the robot to reach the light source.
- **Frequency of Reaching the Light:** How often the robot successfully reaches the light source within the simulation duration.
- **Final Distance to the Light:** The distance between the robot and the light source at the end of the simulation.
