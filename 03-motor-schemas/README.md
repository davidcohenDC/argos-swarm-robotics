# Third Task

The robot is expected to be able to find a light source and go towards it, while 
avoiding collisions  with  other  objects,  such  as  walls,  boxes  and  other  robots.  
The  robot  should reach the target as fast as possible and, once reached it, it should stay
close to it (either standing or moving).  For your convenience, an  argos file defining the 
arena is provided.This defines the distribution of typical arenas for which you have to 
devise your controller.For  physical  constraints  the  wheel  velocity  cannot  exceed  
the  value  15  (i.e.,  15−2m/s).The robot (a footbot) is equipped with light and proximity 
sensors.  In addition, the robot is also equipped with the positioning sensor, which however
can only be used for testing and evaluation purposes.

# Behavioural and Corresponding Potential Fields

1. **Attraction to the light source**: This behavior makes the robot move towards the light source and stay close to it. 
   * **Potential field**: Attractive field.
   * ***Vector Calculation***: The strength of the attraction should be inversely proportional to the distance from the light source.
2. **Obstacle avoidance**:This behavior prevents the robot from colliding with obstacles like walls, boxes, and other robots.
   * ***Potential field***: Repulsive field.
   * ***Vector Calculation***: The strength of the repulsion should be inversely proportional to the distance from the obstacle.
3. Noise: Adding a small random component to the robot's movement to ensure it does not get stuck in local minima.
   * ***Potential field***: Noise field.
   * ***Vector Calculation***: A small random vectors added to the final movement vector.
4. Avoiding past positions: This behavior prevents the robot from getting stuck in a loop. Also avoid 
oscillations between two positions.
   * ***Potential field***:  Repulsive Field from past positions.
   * ***Vector Calculation***:  Similar to obstacle avoidance but with past positions stored in memory.

# Compose the potential fields

The final movement vector for the robot is a weighted sum of the individual vectors from each behavior.
The weights determine the importance of each behavior.

# Translate Vectors into Wheel Velocities
The resulting vector from the potential fields will be translated into wheel velocities for the robot.

## Implementation

1. Initialize the robot with the required sensors and actuators.
   * Light sensor: To detect the light source.
   * Proximity sensor: To detect obstacles.
   * Wheels actuator: To control the movement of the robot.
2. Calculate Attraction Vector: Use the light sensor readings to calculate the vector towards the light source.
3. Calculate Repulsion Vector: Use the proximity sensor readings to calculate the vector away from obstacles.
4. Add Noise Vector: Generate a small random vector.
5. Avoid Past Positions: Store recent positions and calculate a repulsion vector from these positions.
6. Combine Vectors: Weighted sum of attraction, repulsion, noise, and past avoidance vectors.
7. Convert Vector to Wheel Velocities: Translate the resulting vector into left and right wheel velocities.
8. Apply Wheel Velocities: Set the wheel velocities to control the robot's movement.



