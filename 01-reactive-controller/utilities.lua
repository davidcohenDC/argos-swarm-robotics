-- utilities.lua

local utilities = {}

DEBUG = true

--- Function to perceive maximum sensor reading
-- @param sensor_type Type of sensor to use
-- @param sensorIndexes (optional) A table that defines the order of sensor indexes to use
function utilities.getMaxSensorReading(sensor_type, sensorIndexes)
    local max_value, max_index = -1, -1
    for i, sensor in ipairs(sensorIndexes or robot[sensor_type]) do
        local value = sensorIndexes and robot[sensor_type][sensor].value or sensor.value
        if value > max_value then
            max_value, max_index = value, i
        end
    end
    return max_index, max_value
end

--- Logging function
function utilities.log(message)
    if DEBUG then
        log(message)
    end
end


--- Returns wheel speed based on base speed and difference
function utilities.calculateWheelSpeed(baseSpeed, sign, difference)
    return baseSpeed + sign * difference * baseSpeed
end


return utilities
