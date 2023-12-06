local common = require 'common'

local data = common.readlines('data/03.txt')

local gears = {}

local function is_symbol(c, row, col, num)
    -- track gears for part 2
    if c == '*' then
        local key = row .. ',' .. col
        if not gears[key] then
            gears[key] = {}
        end
        table.insert(gears[key], num)
    end

    return c:match '[^%d%.]' ~= nil
end

local function is_part_number(row, s, e, num)
    -- check above
    if row > 1 then
        for i = s - 1, e + 1 do
            if is_symbol(data[row - 1]:sub(i, i), row - 1, i, num) then return true end
        end
    end

    -- check sides
    if is_symbol(data[row]:sub(s - 1, s - 1), row, s - 1, num) or
       is_symbol(data[row]:sub(e + 1, e + 1), row, e + 1, num) then
        return true
    end

    -- check below
    if row < #data then
        for i = s - 1, e + 1 do
            if is_symbol(data[row + 1]:sub(i, i), row + 1, i, num) then return true end
        end
    end
end

local sum = 0
for row, line in ipairs(data) do
    for s, num, e in line:gmatch '()(%d+)()' do
        if is_part_number(row, s, e - 1, num) then
            sum = sum + tonumber(num)
        end
    end
end
print(sum)

sum = 0
for key, list in pairs(gears) do
    local count = 0
    -- add a table.size or table.len function to common
    for _ in ipairs(list) do count = count + 1 end
    if count == 2 then
        sum = sum + (list[1] * list[2])
    end
end
print(sum)
