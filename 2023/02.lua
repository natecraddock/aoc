local common = require 'common'

local games = common.readlines('data/02.txt')

local function parse_game(game)
    local id, sets = game:match('Game (%d+): (.*)')
    return tonumber(id), sets
end

local sum = 0
for _, game in ipairs(games) do
    local id, sets = parse_game(game)

    for match in sets:gmatch('(%d+) red') do
        match = tonumber(match)
        if match > 12 then goto continue end
    end
    for match in sets:gmatch('(%d+) green') do
        match = tonumber(match)
        if match > 13 then goto continue end
    end
    for match in sets:gmatch('(%d+) blue') do
        match = tonumber(match)
        if match > 14 then goto continue end
    end

    sum = sum + id
    ::continue::
end
print(sum)

sum = 0
for _, game in ipairs(games) do
    local _, sets = parse_game(game)
    local maxr, maxg, maxb = 0, 0, 0

    for match in sets:gmatch('(%d+) red') do
        match = tonumber(match)
        if match > maxr then maxr = match end
    end
    for match in sets:gmatch('(%d+) green') do
        match = tonumber(match)
        if match > maxg then maxg = match end
    end
    for match in sets:gmatch('(%d+) blue') do
        match = tonumber(match)
        if match > maxb then maxb = match end
    end

    sum = sum + (maxr * maxg * maxb)
end
print(sum)
