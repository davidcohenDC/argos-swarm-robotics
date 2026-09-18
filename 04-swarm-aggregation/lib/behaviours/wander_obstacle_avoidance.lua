local params = require('hyperparameters')

local prox = require('lib.proximity')
local wander_obstacle_avoidance = {}

wander_obstacle_avoidance.priority = 1

local turning = false
local front_sensors_indices = {1, 2, 3, 4, 5, 20, 21, 22, 23, 24}
local nsteps = 0
local v_left, v_right = 0, 0
local nturns = 0


function wander_obstacle_avoidance.init()
    turning = false
    nsteps = 0
    v_left, v_right = 0, 0
end

function wander_obstacle_avoidance.reset()
    wander_obstacle_avoidance.init()
end

function wander_obstacle_avoidance.destroy()
    -- Cleanup code for wander_obstacle_avoidance behavior
end

function wander_obstacle_avoidance.condition()
    return true
end

function wander_obstacle_avoidance.execute()
    if not turning then
        if not prox.isPathClear(front_sensors_indices) or (nsteps % params.MAXSTEPS == 0) then
            robot.leds.set_all_colors("yellow")
            local v = robot.random.uniform() * params.MAX_VELOCITY
            local r = robot.random.uniform()
            nsteps, nturns, turning = 1, 1, true
            if r >= 0.5 then
                v_left, v_right = v, -v
            else
                v_left, v_right = -v, v
            end
            robot.wheels.set_velocity(v_left, v_right)
        else
            nsteps = nsteps + 1
            robot.wheels.set_velocity(params.MAX_VELOCITY, params.MAX_VELOCITY)

        end
    else
        robot.wheels.set_velocity(v_left, v_right)
        nturns = nturns + 1
        if nturns % params.NTURNS == 0 then
            turning = false
        end
    end
end

return wander_obstacle_avoidance
