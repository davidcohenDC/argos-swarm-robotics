local config = require("config")
local velocity = require("lib.velocity")
local util = require("lib.utilities")
local test_util = require("lib.test_utilities")
local aggressive = require("lib.potential_fields.schemas.aggressive")
local explore = require("lib.potential_fields.schemas.explore")
local past_avoid = require("lib.potential_fields.schemas.past_avoid")

-- State variables
local noise_scale_factor = config.NOISE_FACTOR
local current_force_intensity = config.INITIAL_FORCE_INTENSITY

function init()
    noise_scale_factor = config.NOISE_FACTOR
    current_force_intensity = config.INITIAL_FORCE_INTENSITY
    past_avoid.init(config.MEMORY_STEPS, config.AVOIDANCE_RADIUS)
end

local function reset_force_intensity()
    if current_force_intensity < config.MIN_FORCE_INTENSITY then
        current_force_intensity = config.INITIAL_FORCE_INTENSITY
    end
end

function step()
    util.log("force: " .. current_force_intensity)

    local light_intensity = util.getSumSensorsWithAngleReading('light')
    local combined_vector

    if light_intensity > config.LIGHT_THRESHOLD then
        combined_vector = aggressive.calculate('light', 'proximity',
                current_force_intensity, config.AGGRESSIVE_INTENSITY_MULTIPLIER)
    else
        combined_vector = explore.calculate('light', 'proximity',
                current_force_intensity, config.EXPLORE_INTENSITY_MULTIPLIER, current_force_intensity)
    end

    local left_vel, right_vel = velocity.translational_to_differential(combined_vector, robot.wheels.axis_length)
    robot.wheels.set_velocity(velocity.limit_velocity(left_vel, config.VMAX), velocity.limit_velocity(right_vel, config.VMAX))

    reset_force_intensity()
    current_force_intensity = current_force_intensity * config.FORCE_DECAY_FACTOR

    -- Update the robot's position estimate
    past_avoid.update_location(left_vel, right_vel, robot.wheels.axis_length, config.TIMESTEP)
end

function reset()
    noise_scale_factor = config.NOISE_FACTOR
    current_force_intensity = config.INITIAL_FORCE_INTENSITY
    past_avoid.reset()
end

function destroy()
    util.log("Distance: " .. test_util.getDistance())
end
