local common = require 'common'

local image = common.readlines('data/11.txt', function(line)
    return line:collect('.')
end)

local function distances(growth)
    growth = growth - 1

    -- collect horizontal offsets
    local offsets = {}
    local offset = 0
    for col = 1, #image[1] do
        local galaxy = false
        for row = 1, #image do
            if image[row][col] == '#' then
                galaxy = true
            end
        end
        if not galaxy then
            offset = offset + growth
        end
        table.insert(offsets, offset)
    end

    -- collect all galaxies
    local galaxies = {}
    offset = 0
    for row = 1, #image do
        local galaxy = false
        for col = 1, #image[row] do
            if image[row][col] == '#' then
                galaxy = true
                table.insert(galaxies, { x = col + offsets[col], y = row + offset })
            end
        end
        if not galaxy then
            offset = offset + growth
        end
    end

    -- find distances
    local sum = 0
    for i = 1, #galaxies do
        for j = i + 1, #galaxies do
            sum = sum + math.abs(galaxies[i].x - galaxies[j].x) + math.abs(galaxies[i].y - galaxies[j].y)
        end
    end
    return sum
end

print(distances(2))
print(distances(1000000))
