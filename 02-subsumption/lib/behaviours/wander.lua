--- wander.lua ---

local wander = {}

local util = require('lib.utilities')

wander.priority = 1

local MAX_WANDER_STEPS = 60

-- Probabilities
--local PROB_CHANGE_DIRECTION = 0.7  -- Probability to change direction
--local PROB_CHANGE_SPEED = 0.5      -- Probability to adjust speed
--local DIRECTION_CHANGE_FACTOR = 1  -- Direction change factor
--local SPEED_ADJUSTMENT_RANGE = 0.2  -- Speed adjustment range (20% of BASE_VELOCITY)

local PROB_CHANGE_DIRECTION = 0.8 -- Lower probability to change direction (higher value of change --> better results)
local PROB_CHANGE_SPEED = 0.5 -- Probability to adjust speed (dont change much the results)
local DIRECTION_CHANGE_FACTOR = 0.4 -- Slight direction change factor (higher value means more change )
local SPEED_ADJUSTMENT_RANGE = 0.2 -- Adjust speed within +/-20% of BASE_VELOCITY (lower value means less change --> better results)


local wander_count = 0
local leftSpeed = 0
local rightSpeed = 0

function wander.init()
    -- Initialize wander behavior
end

function wander.condition()
    return true
end

function wander.execute()
    if wander_count == 0 then
        -- Decide whether to change direction
        if math.random() < PROB_CHANGE_DIRECTION then
            local direction_change = (math.random() - 0.5) * 2 * DIRECTION_CHANGE_FACTOR  -- Slight direction change
            leftSpeed = BASE_VELOCITY * (1 + direction_change)
            rightSpeed = BASE_VELOCITY * (1 - direction_change)
        else
            leftSpeed = BASE_VELOCITY
            rightSpeed = BASE_VELOCITY
        end

        -- Decide whether to adjust speed
        if math.random() < PROB_CHANGE_SPEED then
            local speed_adjustment = (math.random() - 0.5) * 2 * SPEED_ADJUSTMENT_RANGE
            leftSpeed = leftSpeed * (1 + speed_adjustment)
            rightSpeed = rightSpeed * (1 + speed_adjustment)
        end

        wander_count = 1
    elseif wander_count < MAX_WANDER_STEPS then
        robot.leds.set_all_colors("blue")
        wander_count = wander_count + 1
    else
        wander_count = 0
    end
    util.log("RW - leftSpeed: " .. leftSpeed .. " rightSpeed: " .. rightSpeed)
    robot.wheels.set_velocity(leftSpeed, rightSpeed)
end

function wander.reset()
    wander_count = 0
end

function wander.destroy()
    -- Clean-up wander behavior
end

return wander