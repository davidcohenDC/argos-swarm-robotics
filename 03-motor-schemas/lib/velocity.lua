-- velocity.lua 
local velocity = {}

function velocity.translational_to_differential(vec, axis_length)
    local half_ang_L = vec.angle * axis_length / 2
    return vec.length - half_ang_L, vec.length + half_ang_L
end

function velocity.limit_velocity(v, VMAX)
    if v > VMAX then
        return VMAX
    elseif v < -VMAX then
        return -VMAX
    else
        return v
    end
end

return velocity