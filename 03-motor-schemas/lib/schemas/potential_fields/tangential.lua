-- tangential.lua
local vector = require("lib.vector")

local tangential = {}

function tangential.calculate(sensor_type, increase_factor)
    increase_factor = increase_factor or 1 -- default value is 1, you can change it as you like
    local tangential_vector = { length = 0, angle = 0 }
    for _, sensor in ipairs(robot[sensor_type]) do
        -- check if exists sensor.angle
        if sensor.angle == nil then
            sensor.angle = 0
        end
        tangential_vector = vector.vec2_polar_sum(
                tangential_vector, { length = sensor.value * increase_factor, angle = sensor.angle + math.pi / 2 })
    end
    return tangential_vector
end
