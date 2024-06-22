local attraction = require("lib.potential_fields.attractive")
local repulsion = require("lib.potential_fields.repulsive")
local uniform = require("lib.potential_fields.uniform")
local config = require("config")
local vector = require("lib.vector")

local aggressive = {}

-- Function to calculate the aggressive vector
function aggressive.calculate(attractive_force, repulsive_force, aggressive_intensity, uniform_factor)
    uniform_factor = uniform_factor or 1 -- default value is 1
    attractive_force = attractive_force or 'light'
    repulsive_force = repulsive_force or 'proximity'
    aggressive_intensity = aggressive_intensity or config.AGGRESSIVE_INTENSITY_MULTIPLIER

    return vector.vecs_polar_combine(
            attraction.calculate('light', config.AGGRESSIVE_INTENSITY_MULTIPLIER),
            repulsion.calculate('proximity', config.AGGRESSIVE_INTENSITY_MULTIPLIER),
            uniform.calculate(uniform_factor))

end

return aggressive