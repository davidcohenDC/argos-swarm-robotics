---** Task 2 **---
local PriorityQueue = require('priority_queue')
local behaviors = PriorityQueue.new()

BASE_VELOCITY = 15

function init()
    behaviors:insert(require('obstacle_avoidance'), 3)
    behaviors:insert(require('phototaxy'), 2)
    behaviors:insert(require('wander'), 1)

    behaviors:for_each(function(behavior)
        behavior.init()
    end)
end

function step()
    senseAndAct()
end

function reset()
    behaviors:for_each(function(behavior)
        behavior.reset()
    end)
    robot.wheels.set_velocity(
            robot.random.uniform(0, BASE_VELOCITY),
            robot.random.uniform(0, BASE_VELOCITY))
    robot.leds.set_all_colors("black")
end

function destroy()
    behaviors:for_each(function(behavior)
        behavior.destroy()
    end)
    x = robot.positioning.position.x
    y = robot.positioning.position.y
    d = math.sqrt((x - 1.5) ^ 2 + y ^ 2)
    print("f_distance " .. d)
end

function senseAndAct()
    behaviors:for_each(function(behavior)
        if behavior.condition() then
            behavior.execute()
            return true
        end
    end)
end