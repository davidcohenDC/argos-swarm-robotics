---** Task 2 **---
local PriorityQueue = require('lib.priority_queue')
local test_util = require('lib.test_utilities')
local behaviors = PriorityQueue.new()

BASE_VELOCITY = 15

function init()
    behaviors:insert(require('lib.behaviours.obstacle_avoidance'), 3)
    behaviors:insert(require('lib.behaviours.phototaxy'), 2)
    behaviors:insert(require('lib.behaviours.wander'), 1)

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
end

function destroy()
    behaviors:for_each(function(behavior)
        behavior.destroy()
    end)

    log("Distance: " .. test_util.getDistance())
end

function senseAndAct()
    behaviors:for_each(function(behavior)
        if behavior.condition() then
            behavior.execute()
            return true
        end
    end)
end