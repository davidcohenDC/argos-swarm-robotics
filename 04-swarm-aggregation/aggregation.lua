local params = require('hyperparameters')
local PriorityQueue = require('lib.priority_queue')
local behaviors = PriorityQueue.new()
local test_utilities = require('lib.test_utilities')
local nRobotSensed = 0

-- Function to count the number of robots sensed
local function CountRAB()
    local number_robot_sensed = 0
    for i = 1, #robot.range_and_bearing do
        if robot.range_and_bearing[i].range < params.MAXRANGE and robot.range_and_bearing[i].data[1] == 1 then
            number_robot_sensed = number_robot_sensed + 1
        end
    end
    return number_robot_sensed
end

local function senseAndAct()
    behaviors:for_each(function(behavior)
        if behavior.condition() then
            behavior.execute()
            return true
        end
    end)
end

function init()
    behaviors:insert(require('lib.behaviours.wander_obstacle_avoidance'), 1)
    behaviors:insert(require('lib.behaviours.walk'), 2)
    behaviors:insert(require('lib.behaviours.stop'), 3)

    behaviors:for_each(function(behavior)
        behavior.init()
    end)
end

function step()
    nRobotSensed = CountRAB()
    local t = robot.random.uniform()  -- random number
    if STATE == params.states.WALK then
        senseAndAct()
        local Ps = math.min(params.PSMAX, params.S + params.ALPHA * nRobotSensed)  -- stopping probability
        if t <= Ps then
            STATE = params.states.STOP
        end
    elseif STATE == params.states.STOP then
        senseAndAct()
        local Pw = math.max(params.PWMIN, params.W - params.BETA * nRobotSensed)  -- walking probability
        if t <= Pw then
            STATE = params.states.WALK
        end
    end
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
    log("Average Neighbor Distance: " .. test_utilities.getAverageNeighborDistance())
end
