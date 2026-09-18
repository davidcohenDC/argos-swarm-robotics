# Behaviour

* Random walk 
* Obstacle avoidance
* Stopping probability Ps (Ps depends on numbers of robots nearby already stopped
  The higher the number of robots nearby already stopped, the higher the probability of stopping) --> Positive feedback loop
* Starting probability Pw (Pw depends on numbers of robots nearby already stopped
  The higher the number of robots nearby already stopped, the lower the probability of starting) --> Negative feedback loop

# Data

Let S \in {0, 1} spontaneous stopping event
Let W \in {0, 1} spontaneous starting event
Let N the number of robots nearby already stopped

The probability can be updated as follows:
Ps = min{PsMax, S + α * N}
Pw = max{PwMin, W - β * N}
For a rectangular arena of 4×5 meters, 50 robots and a maximal range of 30 cm, you may initially try with:
- W= 0.1,
- S= 0.01,
- PsMax= 0.99,
- PwMin= 0.005,
- α= 0.1,
- β= 0.05

# Range adn bearing system
The range-and-bearing system allows robots to perform localized communication, meaning that upon receiving data from 
another robot, a robot can also detect the position of the sender relative to its local point of view. This system has unique characteristics:

* Communication requires a direct line of sight.
* Data broadcasting is limited to a specific area.
* Data exchange is limited to 10 bytes per message.

**Commands**

`setdata(idx, data)`:Sets a specific byte in the data to broadcast.

* **Parameters**:

  * **idx** (integer): The index of the byte to set, ranging from 0 to 9.
  * **data** (integer): The value to set the byte to, ranging from 0 to 255.
  Example:

```LUA
setdata(2, 150)  -- Sets the 3rd byte (index 2) to 150
```
`setdata(data)`:Sets all 10 bytes in the data to broadcast.

* **Parameters**:

  * **data** (table): A table containing exactly 10 integer numbers, each ranging from 0 to 255.
  Example:

```LUA
setdata({10, 20, 30, 40, 50, 60, 70, 80, 90, 100})  -- Sets all 10 bytes
```

`writedata(data)`:Writes the data received from another robot.

* **Parameters**:

  * **data** (table): A table containing the received data.
* Example:

```LUA
function processMessages(messages)
    for i, message in ipairs(messages) do
        local data = message.data
        writedata(data)
    end
end
```

**Receiving Messages**

At each time step, a robot receives a variable number of messages from nearby robots. Each message contains the following fields:

* **data** (table): The 10-byte message payload.
* **horizontalbearing** (float): The angle between the robot's local x-axis and the position of the message source, measured in radians on the robot’s xy-plane.
* **verticalbearing** (float): The angle between the message source and the robot’s xy-plane, indicating elevation.
* **range** (float): The distance to the message source, measured in centimeters.

**Example Usage**

```lua
-- Setting the data to broadcast
setdata({5, 10, 15, 20, 25, 30, 35, 40, 45, 50})

-- Function to process incoming messages
function processMessages(messages)
    for i, message in ipairs(messages) do
        local data = message.data
        local h_bearing = message.horizontalbearing
        local v_bearing = message.verticalbearing
        local range = message.range

        -- Example processing
        print("Received data: ", data)
        print("Horizontal bearing: ", h_bearing)
        print("Vertical bearing: ", v_bearing)
        print("Range: ", range)
    end
end

-- Example call to process messages

local received_messages = {
    {data = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50}, horizontalbearing = 0.5, verticalbearing = 0.1, range = 100},
    {data = {15, 20, 25, 30, 35, 40, 45, 50, 55, 60}, horizontalbearing = 1.2, verticalbearing = 0.3, range = 150}
}

processMessages(received_messages)
```


# Exercise 1

Implement the aggregation behaviour according to the model described above.  Of course,you can also implement your
own aggregation mechanism. Experiment with different values
for S,W,α and β.  The behaviour can be modelled by means of 
a probabilistic automaton (o visually inspect the overall behaviour, use LEDs coloured depending on the state of the automaton.
```lua
Ps = math.min(PsMax, S + alpha * N)
Pw = math.max(PwMin, W - beta * N)
```
For implementing the probabilistc decision mechanism (based on a Bernoulli distribution, with probability p):
```lua
t=robot.random.uniform()
if t < p then
--    do something
else 
--    do something else
end
```