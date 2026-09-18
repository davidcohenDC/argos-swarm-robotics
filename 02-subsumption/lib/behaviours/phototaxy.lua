--- phototaxy.lua ---

local phototaxy = {}
local util = require('lib.utilities')

phototaxy.priority = 2

local MINIMUM_LIGHT_INTENSITY = 0.09

function phototaxy.init()
    -- Initialize phototaxy behavior
end

function phototaxy.condition()
    local _, maxLightIntensity = util.getMaxSensorReading('light')
    return maxLightIntensity > MINIMUM_LIGHT_INTENSITY
end

function phototaxy.execute()
    local maxLightIndex, maxLightIntensity = util.getMaxSensorReading('light')
    robot.leds.set_all_colors("white")
    util.log("P - maxLightIndex: " .. maxLightIndex .. " maxLightIntensity: " .. maxLightIntensity)
    local angle = (maxLightIndex - 1) * (2 * math.pi / #robot.light)
    local difference = math.sin(angle)
    local leftWheelSpeed = util.calculateWheelSpeed(BASE_VELOCITY, -1, difference)
    local rightWheelSpeed = util.calculateWheelSpeed(BASE_VELOCITY, 1, difference)
    robot.wheels.set_velocity(leftWheelSpeed, rightWheelSpeed)
end

function phototaxy.reset()
    -- Reset phototaxy behavior
end

function phototaxy.destroy()
    -- Clean-up phototaxy behavior
end

return phototaxy