--- obstacle_avoidance.lua

local util = require('utilities')
local proximity = require('proximity')

local avoid_obstacle = {}

avoid_obstacle.priority = 3

local BASE_VELOCITY = 15
local PROXIMITY_THRESHOLD = 0.1
local EMERGENCY_VELOCITY_FACTOR = 0.5
local OBSTACLE_AVOIDANCE_SPEED_FACTOR = 0.5
local front_sensors = {1, 2, 3, 4, 5, 20, 21, 22, 23, 24}

function avoid_obstacle.init()
    -- Initialization code for avoid_obstacle behavior
end

function avoid_obstacle.reset()
    -- Reset code for avoid_obstacle behavior
end

function avoid_obstacle.destroy()
    -- Cleanup code for avoid_obstacle behavior
end

function avoid_obstacle.condition()
    return not proximity.isPathClear(front_sensors)
end

function avoid_obstacle.execute()
    local maxProximityIndex, maxProximityIntensity = util.getMaxSensorReading('proximity', front_sensors)
    if maxProximityIntensity > PROXIMITY_THRESHOLD * 2 then
        robot.leds.set_all_colors("red")
        util.log("OA - Emergency rotation! maxProximityIndex: " .. maxProximityIndex .. " maxProximityIntensity: " .. maxProximityIntensity)
        robot.wheels.set_velocity(BASE_VELOCITY * EMERGENCY_VELOCITY_FACTOR, -BASE_VELOCITY * EMERGENCY_VELOCITY_FACTOR)
    elseif maxProximityIntensity > PROXIMITY_THRESHOLD then
        robot.leds.set_all_colors("yellow")
        util.log("OA - maxProximityIndex: " .. maxProximityIndex .. " maxProximityIntensity: " .. maxProximityIntensity)
        local angle = (maxProximityIndex - 1) * (2 * math.pi / #robot.proximity)
        local difference = math.sin(angle)
        local leftWheelSpeed, rightWheelSpeed = util.calculateTwoWheelSpeed(
                BASE_VELOCITY * OBSTACLE_AVOIDANCE_SPEED_FACTOR,  difference)

        robot.wheels.set_velocity(leftWheelSpeed, rightWheelSpeed)
    end
end

return avoid_obstacle
