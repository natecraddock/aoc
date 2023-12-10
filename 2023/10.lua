local common = require 'common'

local grid = {}

local current = { y = 1 }
for line in io.lines('data/10.txt') do
    local pos = line:find('S')
    if pos then
        current.x = pos
    end

    table.insert(grid, line:collect('.'))

    if not current.x then
        current.y = current.y + 1
    end
end

-- finding the start is messy
local right = grid[current.y][current.x + 1]
local left = grid[current.y][current.x - 1]
local up = grid[current.y - 1][current.x]
local down = grid[current.y + 1][current.x]

local last
if right == '-' or right == 'J' or right == '7' then
    last = 'right'
    current.x = current.x + 1
elseif left == '-' or left == 'L' or left == 'F' then
    last = 'left'
    current.x = current.x - 1
elseif up == '|' or up == 'F' or up == '7' then
    last = 'up'
    current.y = current.y - 1
elseif down == '|' or down == 'L' or down == 'J' then
    last = 'down'
    current.y = current.y + 1
end

local steps = 0
local path = { [current.y .. ',' .. current.x] = true }
while grid[current.y][current.x] ~= 'S' do
    local symbol = grid[current.y][current.x]

    if symbol == '|' then
        current.y = current.y + (last == 'up' and -1 or 1)
    elseif symbol == '-' then
        current.x = current.x + (last == 'right' and 1 or -1)
    elseif symbol == 'L' then
        if last == 'down' then
            current.x = current.x + 1
            last = 'right'
        else
            current.y = current.y - 1
            last = 'up'
        end
    elseif symbol == 'J' then
        if last == 'down' then
            current.x = current.x - 1
            last = 'left'
        else
            current.y = current.y - 1
            last = 'up'
        end
    elseif symbol == '7' then
        if last == 'up' then
            current.x = current.x - 1
            last = 'left'
        else
            current.y = current.y + 1
            last = 'down'
        end
    elseif symbol == 'F' then
        if last == 'up' then
            current.x = current.x + 1
            last = 'right'
        else
            current.y = current.y + 1
            last = 'down'
        end
    end

    steps = steps + 1
    path[current.y .. ',' .. current.x] = true
end
print(math.ceil(steps / 2))

-- Part 2
local num_inside = 0
for y, row in ipairs(grid) do
    local inside = false

    for x, pipe in ipairs(row) do
        -- only consider valid paths
        if path[y .. ',' .. x] then
            if pipe == '|' or pipe == 'S' then
                inside = not inside
            elseif pipe == 'F' then
                while row[x + 1] == '-' do x = x + 1 end
                if row[x + 1] == 'J' then
                    inside = not inside
                end
            elseif pipe == 'L' then
                while row[x + 1] == '-' do x = x + 1 end
                if row[x + 1] == '7' then
                    inside = not inside
                end
            end
        elseif inside then
            grid[y][x] = 'I'
            num_inside = num_inside + 1
        else
            grid[y][x] = ' '
        end
    end
end
print(num_inside)
