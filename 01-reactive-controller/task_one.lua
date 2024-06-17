---** Constants (Global variables) **---
MOVE_STEPS = 15                    -- Step interval for random movement
BASE_VELOCITY = 15                 -- Base velocity for the robot
LIGHT_THRESHOLD = 1                -- Threshold for light detection
PROXIMITY_THRESHOLD = 0.15         -- Threshold for proximity sensor (more sensitive)
OBSTACLE_AVOIDANCE_SPEED_FACTOR = 0.5  -- variabile globale
CLEAR_PATH_THRESHOLD = 0.02        -- Threshold for determining a clear path
RANDOM_WALK_STEPS = 40             -- Step interval for random movement

-- Variables
local random_walk_steps = 0
local leftSpeed = 0
local rightSpeed = 0
local front_sensors = {1, 2, 3, 4, 5, 6, 19, 20, 21, 22, 23, 24}

---** Require Utilities **---
local utilities = require("utilities")
local proximity = require("proximity")

function init()
    reset()
end

local function phototaxyTask()
    -- Gets the index and intensity of the maximum light
    local maxLightIndex, maxLightIntensity = utilities.getMaxSensorReading('light')
    -- If the maximum light intensity is high enough, stop the robot
    if maxLightIntensity > 0 then
        robot.leds.set_all_colors("white")
        utilities.log("P - maxLightIndex: " .. maxLightIndex .. " maxLightIntensity: " .. maxLightIntensity)
        -- Calculates the difference between the right and left side of the robot based on the sensor index with maximum light intensity
        local angle = (maxLightIndex - 1) * (2 * math.pi / #robot.light)
        local difference = math.sin(angle)
        local leftWheelSpeed = utilities.calculateWheelSpeed(BASE_VELOCITY, -1, difference)
        local rightWheelSpeed = utilities.calculateWheelSpeed(BASE_VELOCITY, 1, difference)
        robot.wheels.set_velocity(leftWheelSpeed, rightWheelSpeed)
        return true
    end
    return false
end

--- Function to avoid obstacles, similar to phototaxy, is the opposite of it
local function obstacleAvoidanceTask()
    -- Gets the index and intensity of the maximum proximity sensor
    local maxProximityIndex, maxProximityIntensity = utilities.getMaxSensorReading('proximity', front_sensors)

    if not proximity.isPathClear(front_sensors) then
        -- If the maximum proximity intensity is high enough, rotate the robot in place
        if maxProximityIntensity > PROXIMITY_THRESHOLD * 2 then
            robot.leds.set_all_colors("red")
            utilities.log("OA - Emergency rotation! maxProximityIndex: " .. maxProximityIndex .. " maxProximityIntensity: " .. maxProximityIntensity)
            -- Rotate in place
            robot.wheels.set_velocity(BASE_VELOCITY, -BASE_VELOCITY)
            return true
        elseif maxProximityIntensity > PROXIMITY_THRESHOLD then
            robot.leds.set_all_colors("yellow")
            utilities.log("OA - maxProximityIndex: " .. maxProximityIndex .. " maxProximityIntensity: " .. maxProximityIntensity)
            -- Calculates the difference between the right and left side of the robot based on the sensor index with maximum proximity intensity
            local angle = (maxProximityIndex - 1) * (2 * math.pi / #robot.proximity)
            local difference = math.sin(angle)
            local leftWheelSpeed = utilities.calculateWheelSpeed(BASE_VELOCITY * OBSTACLE_AVOIDANCE_SPEED_FACTOR,
                    1, difference)
            local rightWheelSpeed = utilities.calculateWheelSpeed(BASE_VELOCITY * OBSTACLE_AVOIDANCE_SPEED_FACTOR,
                    -1, difference)
            robot.wheels.set_velocity(leftWheelSpeed, rightWheelSpeed)
            return true
        end
    end


    return false
end

local function randomWalkTask()
    if random_walk_steps == 0 then
        -- Random speeds for general movement
        leftSpeed = math.random(0, BASE_VELOCITY)
        rightSpeed = math.random(0, BASE_VELOCITY)
        random_walk_steps = 1
    elseif random_walk_steps < RANDOM_WALK_STEPS then
        robot.leds.set_all_colors("blue")
        random_walk_steps = random_walk_steps + 1
    else
        random_walk_steps = 0
    end
    utilities.log("RW - leftSpeed: " .. leftSpeed .. " rightSpeed: " .. rightSpeed)
    robot.wheels.set_velocity(leftSpeed, rightSpeed)
end

function step()
    if not obstacleAvoidanceTask() and not phototaxyTask() then
        randomWalkTask()
    end
    return
end
-- This function is executed every time you press 'reset' in the GUI
function reset()
    robot.wheels.set_velocity(
            robot.random.uniform(0, BASE_VELOCITY),
            robot.random.uniform(0, BASE_VELOCITY))
    robot.leds.set_all_colors("black")
    random_walk_steps = 0
end

-- This function is executed only once, when the robot is removed from the simulation
function destroy()
    -- put your code here
end
