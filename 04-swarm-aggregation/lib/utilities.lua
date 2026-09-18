local params = require('params')
local utilities = {}

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

function utilities.getMaxSensorWithAngleReading(sensor_type, sensorIndexes)
    local max_value, max_index, max_angle = 0, 0, 0
    for i, sensor in ipairs(sensorIndexes or robot[sensor_type]) do
        local value = sensorIndexes and robot[sensor_type][sensor].value or sensor.value
        max_angle = sensorIndexes and robot[sensor_type][sensor].angle or sensor.angle
        if value > max_value then
            max_value, max_index = value, i
        end
    end
    return max_index, max_value, max_angle
end

function utilities.getSumSensorsWithAngleReading(sensor_type, sensorIndexes)
    local sum_value, angle = 0, 0
    for _, sensor in ipairs(sensorIndexes or robot[sensor_type]) do
        local value = sensorIndexes and robot[sensor_type][sensor].value or sensor.value
        angle = sensorIndexes and robot[sensor_type][sensor].angle or sensor.angle
        sum_value = sum_value + value
    end
    return sum_value, angle
end

--- Logging function
function utilities.log(message)
    if params.DEBUG then
        log(message)
    end
end

--- Returns wheel speed based on base speed and difference
function utilities.calculateWheelSpeed(baseSpeed, sign, difference)
    return baseSpeed + sign * difference * baseSpeed
end

return utilities
