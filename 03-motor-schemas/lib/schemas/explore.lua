-- explore.lua
local attraction = require("lib.schemas.potential_fields.attractive")
local repulsion = require("lib.schemas.potential_fields.repulsive")
local uniform = require("lib.schemas.potential_fields.uniform")
local noise = require("lib.schemas.noise")
local past_avoid = require("lib.schemas.past_avoid")
local config = require("config")
local vector = require("lib.vector")

local explore = {}

-- Function to calculate the exploration vector
-- This function combines the attractive and repulsive forces
-- to calculate the exploration vector
function explore.calculate(attractive_force, repulsive_force, explore_intensity, uniform_factor, increase_factor)
    uniform_factor = uniform_factor or 1 -- default value is 1
    increase_factor = increase_factor or 1 -- default value is 1
    explore_intensity = explore_intensity or config.EXPLORE_INTENSITY_MULTIPLIER
    attractive_force = attractive_force or 'light'
    repulsive_force = repulsive_force or 'proximity'


    return vector.vecs_polar_combine(
            attraction.calculate(attractive_force, explore_intensity),
            repulsion.calculate(repulsive_force, explore_intensity),
            attraction.calculate(repulsive_force),
            uniform.calculate(uniform_factor),
            noise.calculate(config.NOISE_FACTOR, increase_factor),
            past_avoid.calculate(increase_factor, config.AVOIDANCE_RADIUS)
    )

end

return explore
