local common = require 'common'

local platform = common.readlines('data/14.txt', function(line)
    return line:collect('.')
end)

local function simulate()
    for col = 1, #platform[1] do
        for row = 1, #platform do
            if platform[row][col] == 'O' then
                local r = row - 1
                while platform[r] and platform[r][col] == '.' do
                    platform[r][col], platform[r + 1][col] = platform[r + 1][col], platform[r][col]
                    r = r - 1
                end
            end
        end
    end
end
simulate()

local function compute_load()
    local load = 0
    for i, row in ipairs(platform) do
        for _, cell in ipairs(row) do
            if cell == 'O' then
                load = load + (#platform - (i - 1))
            end
        end
    end
    return load
end

print(compute_load())

local function rotate(tbl)
    local new = {}
    for col = 1, #tbl[1] do
        table.insert(new, {})
        for row = #tbl, 1, -1 do
            table.insert(new[col], tbl[row][col])
        end
    end
    return new
end

local load = 0
for i = 2, 1000000000 do
    platform = rotate(platform)

    if i % 4 == 1 then
        local l = compute_load()
        print(i, l)
        -- if l == load then
        --     break
        -- end
        load = l
    end

    simulate()
end
