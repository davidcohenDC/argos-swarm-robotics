-- noise.lua
local noise = {}

function noise.calculate(factor, intensity)
    factor = factor or 1
    intensity = intensity or 1
    local noise_length = math.random() * factor + (intensity / 2)
    local noise_angle = math.random() * (2 * math.pi)
    return { length = noise_length, angle = noise_angle }
end

return noise