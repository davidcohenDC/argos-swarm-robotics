local params = require('hyperparameters')
local test_utilities = {}

-- Function to read the ARGoS configuration file and obtain the light position
local function get_light_position_from_argos(config_file)
    local light_position = {x = 0, y = 0}

    -- Open the ARGoS configuration file for reading
    local file = io.open(config_file, "r")
    if not file then
        error("Could not open ARGoS configuration file: " .. config_file)
    end

    -- Read the file line by line
    for line in file:lines() do
        -- Match the line that contains the light position
        local x, y = line:match('<light id="light".-position="([0-9.-]+),([0-9.-]+),')
        if x and y then
            light_position.x = tonumber(x)
            light_position.y = tonumber(y)
            break
        end
    end

    -- Close the file
    file:close()
    return light_position
end

-- Get the configuration file path from the environment variable
local config_file = os.getenv("ARGOS_CONFIG_FILE")
if not config_file then
    config_file = params.CONFIG_FILE
end

-- Get the light position from the ARGoS configuration
local LIGHT_POSITION = get_light_position_from_argos(config_file)

-- Log the distance from the light source
function test_utilities.getDistance()
    return math.sqrt(
            (robot.positioning.position.x - LIGHT_POSITION.x)^2 +
                    (robot.positioning.position.y - LIGHT_POSITION.y)^2
    )
end

return test_utilities
