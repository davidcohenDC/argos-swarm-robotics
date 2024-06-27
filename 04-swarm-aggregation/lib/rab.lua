-- rab.lua
local params = require('hyperparameters')
local rab = {}

function rab.countRobotsInRange()
    local number_robot_sensed = 0
    for i = 1, #robot.range_and_bearing do
        -- for each robot seen, check if it is close enough.
        if robot.range_and_bearing[i].range < params.MAXRANGE and robot.range_and_bearing[i].data[1] == 1 then
            number_robot_sensed = number_robot_sensed + 1
        end
    end
    return number_robot_sensed
end

return rab
