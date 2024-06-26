-- past_avoid.lua
local vector = require("lib.vector")
local config = require("config")

local past_avoid = {}

-- Internal state for past avoidance
local visited_locations = {}
local initial_position = { x = 0, y = 0, theta = 0 } -- Including theta for orientation

local MEMORY_STEPS = 20 or config.MEMORY_STEPS
local AVOIDANCE_RADIUS = 0.1 or config.AVOIDANCE_RADIUS


function past_avoid.init(memory_steps, avoidance_radius)
    MEMORY_STEPS = memory_steps or MEMORY_STEPS
    AVOIDANCE_RADIUS = avoidance_radius or AVOIDANCE_RADIUS
    visited_locations = { initial_position }
end

function past_avoid.reset()
    visited_locations = { initial_position }
end

local function calculate_distance(pos1, pos2)
    return math.sqrt((pos1.x - pos2.x)^2 + (pos1.y - pos2.y)^2)
end

function past_avoid.update_location(left_vel, right_vel, axis_length, timestep)
    local last_position = visited_locations[#visited_locations]
    local x, y, theta = last_position.x, last_position.y, last_position.theta

    local v = (left_vel + right_vel) / 2
    local w = (right_vel - left_vel) / axis_length

    local delta_theta = w * timestep
    local delta_x = v * math.cos(theta) * timestep
    local delta_y = v * math.sin(theta) * timestep

    local new_position = {
        x = x + delta_x,
        y = y + delta_y,
        theta = theta + delta_theta
    }
    table.insert(visited_locations, new_position)

    -- Limit the number of steps preserved
    if #visited_locations > MEMORY_STEPS then
        table.remove(visited_locations, 1)
    end
end

function past_avoid.has_recently_visited()
    return #visited_locations > 1
end


function past_avoid.calculate(current_force_intensity)
    local repulsion_vector = { length = 0, angle = 0 }
    local current_position = visited_locations[#visited_locations]
    for _, location in ipairs(visited_locations) do
        local distance = calculate_distance(current_position, location)
        if distance < AVOIDANCE_RADIUS then
            local angle = math.atan2(current_position.y - location.y, current_position.x - location.x)
            repulsion_vector = vector.vec2_polar_sum(repulsion_vector, { length = (AVOIDANCE_RADIUS - distance) * current_force_intensity, angle = angle })
        end
    end
    return repulsion_vector
end

return past_avoid
