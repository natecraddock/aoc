local common = require 'common'

local iter = io.lines('data/08.txt')

local instructions = iter():collect('.')

-- skip blank line
iter()

-- collect nodes
local nodes = {}
while true do
    local node = iter()
    if not node then break end

    local node, left, right = node:match('(%w+) = %((%w+), (%w+)%)')
    nodes[node] = { L = left,  R = right }
end

-- part 1
local steps = 0
local current = 'AAA'
while false do
    for _, dir in ipairs(instructions) do
        steps = steps + 1
        current = nodes[current][dir]
    end
    if current == 'ZZZ' then break end
end
print(steps)

-- part 2
local current = {}
for node in pairs(nodes) do
    if node:sub(3, 3) == 'A' then
        table.insert(current, { steps = 0, current = node })
    end
end

for _, node in ipairs(current) do
    steps = 0
    while true do
        for _, dir in ipairs(instructions) do
            steps = steps + 1
            node.current = nodes[node.current][dir]
        end
        if node.current:sub(3, 3) == 'Z' then break end
    end
    node.steps = steps
end

local lcm = 1
for _, node in ipairs(current) do
    lcm = common.lcm(lcm, node.steps)
end
print(lcm)
