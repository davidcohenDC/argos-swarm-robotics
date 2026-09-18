local params = require('hyperparameters')
local stop = {}

stop.priority = 3

function stop.init()
    -- Initialize stop behavior
end

function stop.condition()
    return STATE == params.states.STOP
end

function stop.execute()
    robot.leds.set_all_colors("red")
    robot.range_and_bearing.set_data(1, 1)
    robot.wheels.set_velocity(0, 0)
end

function stop.reset()
    -- Reset stop behavior
end

function stop.destroy()
    -- Clean-up stop behavior
end

return stop
