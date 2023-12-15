local common = require 'common'

local sequence = common.readall('data/15.txt')

local steps = sequence:collect '[^,]+'

local function HASH(s)
    local res = 0
    for i = 1, #s do
        res = res + s:byte(i)
        res = res * 17
        res = res % 256
    end
    return res
end

-- part 1
local sum = 0
for _, step in ipairs(steps) do
    sum = sum + HASH(step)
end
print(sum)

-- part 2
local function parse(step)
    local label = step:match('%a+')
    local op = step:match('[-=]')
    local f = step:match('%d+')
    return label, op, tonumber(f)
end

local boxes = {}
for _, step in ipairs(steps) do
    local label, op, f = parse(step)

    local index = HASH(label) + 1
    boxes[index] = boxes[index] or {}
    local box = boxes[index]

    if op == '-' then
        local idx = table.find(box, nil, function(v) return v.label == label end)
        if idx then table.remove(box, idx) end
    else
        local idx = table.find(box, nil, function(v) return v.label == label end)
        if idx then
            box[idx].f = f
        else
            table.insert(box, { label = label, f = f })
        end
    end
end

local power = 0
for i = 1, 256 do
    local box = boxes[i]
    if box then
        for slot, lens in ipairs(box) do
            power = power + (i * slot * lens.f)
        end
    end
end
print(power)
