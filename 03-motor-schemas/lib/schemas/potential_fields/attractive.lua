-- attractive.lua
local vector = require("lib.vector")

local attractive = {}

function attractive.calculate(sensor_type, increase_factor)
    increase_factor = increase_factor or 1 -- default value is 1, you can change it as you like
    local attraction_vector = { length = 0, angle = 0 }
    for _, sensor in ipairs(robot[sensor_type]) do
        -- check if exists sensor.angle
        if sensor.angle == nil then
            sensor.angle = 0
        end
        attraction_vector = vector.vec2_polar_sum(
                attraction_vector, { length = sensor.value * increase_factor, angle = sensor.angle })
    end
    return attraction_vector
end

return attractive