local params = require('hyperparameters')
local test_utilities = {}

-- Get the configuration file path from the environment variable
local config_file = os.getenv("ARGOS_CONFIG_FILE")
if not config_file then
    config_file = params.CONFIG_FILE
end


-- Get the average distance to all neighbors
function test_utilities.getAverageNeighborDistance()
    local total_distance = 0
    local neighbor_count = #robot.range_and_bearing
    for i = 1, neighbor_count do
        total_distance = total_distance + robot.range_and_bearing[i].range
    end
    if neighbor_count > 0 then
        return total_distance / neighbor_count
    else
        return 0
    end
end

return test_utilities
