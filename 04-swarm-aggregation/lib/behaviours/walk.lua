local params = require('hyperparameters')
local walk = {}

walk.priority = 2

local wander_obstacle_avoidance = require("lib.behaviours.wander_obstacle_avoidance")

function walk.init()
    log("walk behavior initialized")
end

function walk.condition()
    return STATE == params.states.WALK
end

function walk.execute()
    robot.leds.set_all_colors("green")
    robot.range_and_bearing.set_data(1, 0)
    wander_obstacle_avoidance.execute()  -- Invoke the low-level behavior
end

function walk.reset()
    -- Reset walk behavior
end

function walk.destroy()
    -- Clean-up walk behavior
end

return walk
