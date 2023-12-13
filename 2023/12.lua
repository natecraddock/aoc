local common = require 'common'

local data = common.readlines('data/12.txt', function(line)
    local row, damage = line:match('([?#%.]+) (.+)')
    damage = damage:collect('%d+')
    return { row = row, damage = damage }
end)

local count
count = common.memoize(function(row, damage)
    -- base case
    if #row == 0 then
        if #damage == 0 then return 1 end
        return 0
    end

    -- handle case where there are no more runs of contiguous damaged springs,
    -- but there are more damaged springs in the remaining text
    if #damage == 0 then
        for i = 1, #row do
            if row:sub(i, i) == '#' then return 0 end
        end
        return 1
    end

    -- remaining length not long enough to contain remaining damaged springs
    if #row < table.sum(damage) + #damage - 1 then
        return 0
    end

    -- leading dots can be ignored
    if row:sub(1, 1) == '.' then
        return count(row:sub(2), damage)
    end

    -- try to see how many more damaged springs fit from this point on
    if row:sub(1, 1) == '#' then
        local current, rest = damage[1], { select(2, table.unpack(damage)) }
        for i = 1, current do
            -- not enough room
            if row:sub(i, i) == '.' then return 0 end
        end

        -- run too long!
        if row:sub(current + 1, current + 1) == '#' then return 0 end

        return count(row:sub(current + 2), rest)
    end

    return count('#' .. row:sub(2), damage) + count('.' .. row:sub(2), damage)
end)

local sum = 0
for _, spring in ipairs(data) do
    sum = sum + count(spring.row, spring.damage)
end
print(sum)

sum = 0
for _, spring in ipairs(data) do
    spring.row = table.concat(table.new(spring.row, 5), '?')
    local damage = {}
    for i = 1, 5 do
        for _, d in ipairs(spring.damage) do table.insert(damage, d) end
    end
    sum = sum + count(spring.row, damage)
end
print(sum)
