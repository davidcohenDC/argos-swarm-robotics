-- uniform.lua

local uniform = {}

function uniform.calculate(increase_factor)
    increase_factor = increase_factor or 1 -- default value is 1, you can change it as you like
    return { length = increase_factor, angle = 0 }
end

return uniform