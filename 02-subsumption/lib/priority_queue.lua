--- priority_queue.lua ---

local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

function PriorityQueue.new()
    return setmetatable({items = {}}, PriorityQueue)
end

function PriorityQueue:insert(item, priority)
    table.insert(self.items, {item = item, priority = priority})
    table.sort(self.items, function(a, b) return a.priority > b.priority end)
end

function PriorityQueue:for_each(callback)
    for _, element in ipairs(self.items) do
        if callback(element.item) then
            break
        end
    end
end

return PriorityQueue
