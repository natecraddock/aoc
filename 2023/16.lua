local common = require 'common'

local grid = common.readlines('data/16.txt', function(line)
    return line:collect('.')
end)

local function simulate(y, x, vy, vx)
    -- track important events for each mirror to catch duplicate paths
    local events = {}
    for i = 1, #grid do
        table.insert(events, {})
        for j = 1, #grid[1] do
            table.insert(events[i], {})
        end
    end

    -- track the number of visited cells
    local visited = {}

    local beams = { { y = y, x = x, vy = vy, vx = vx } }
    while #beams > 0 do
        local new_beams = {}

        for _, beam in ipairs(beams) do
            -- out of bounds
            if beam.y < 1 or beam.y > #grid or beam.x < 1 or beam.x > #grid[beam.y] then
                goto continue
            end

            local cell = grid[beam.y][beam.x]
            visited[beam.y .. ',' .. beam.x] = true

            if cell ~= '.' and events[beam.y][beam.x][beam.vy .. ',' .. beam.vx] then
                goto continue
            elseif cell ~= '.' then
                events[beam.y][beam.x][beam.vy .. ',' .. beam.vx] = true
            end

            -- update direction and split if needed
            if cell == '/' then
                if beam.vy ~= 0 then
                    beam.vx = beam.vy * -1
                    beam.vy = 0
                else
                    beam.vy = beam.vx * -1
                    beam.vx = 0
                end
            elseif cell == '\\' then
                if beam.vy ~= 0 then
                    beam.vx = beam.vy
                    beam.vy = 0
                else
                    beam.vy = beam.vx
                    beam.vx = 0
                end
            elseif cell == '-' then
                if beam.vy ~= 0 then
                    beam.vy = 0
                    beam.vx = 1
                    table.insert(new_beams, { y = beam.y, x = beam.x, vy = 0, vx = -1 })
                end
            elseif cell == '|' then
                if beam.vx ~= 0 then
                    beam.vy = 1
                    beam.vx = 0
                    table.insert(new_beams, { y = beam.y, x = beam.x, vy = -1, vx = 0 })
                end
            end

            -- move the beam
            beam.y = beam.y + beam.vy
            beam.x = beam.x + beam.vx

            table.insert(new_beams, beam)

            ::continue::
        end

        beams = new_beams
    end

    return table.len(visited)
end

-- part 1
print(simulate(1, 1, 0, 1))

-- part 2
local max = 0
for y = 1, #grid do
    local count = simulate(y, 1, 0, 1)
    if count > max then max = count end
    count = simulate(y, #grid[1], 0, -1)
    if count > max then max = count end
end
for x = 1, #grid[1] do
    local count = simulate(1, x, 1, 0)
    if count > max then max = count end
    count = simulate(#grid, x, -1, 0)
    if count > max then max = count end
end
print(max)
