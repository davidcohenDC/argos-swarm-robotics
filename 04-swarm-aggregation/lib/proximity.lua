local params = require('hyperparameters')
local proximity = {}

--- Function to check if the path ahead is clear
function proximity.isPathClear(front_sensors, clear_path_threshold)
    clear_path_threshold = clear_path_threshold or params.CLEAR_PATH_THRESHOLD
    for _, i in ipairs(front_sensors) do
        if robot.proximity[i].value > clear_path_threshold then
            return false
        end
    end
    return true
end

return proximity
