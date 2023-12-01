local common = require 'common'

local data = common.readlines('data/01.txt')

local sum = 0
for _, line in ipairs(data) do
    local a, b
    for d in line:gmatch('%d') do
        -- this ensures a is only set once, and b will be set to the last digit or be left nil
        if not a then a = d else b = d end
    end
    sum = tonumber(a .. (b or a)) + sum
end

print(sum)

local options = { one = 1, two = 2, three = 3, four = 4, five = 5, six = 6, seven = 7, eight = 8, nine = 9, ['(%d)'] = false }

sum = 0
for _, line in ipairs(data) do
    local min, max = math.maxinteger, math.mininteger
    local a, b = 0, 0

    for pattern in pairs(options) do
        -- find the maximum and minimum position of the substring
        for pos, num in line:gmatch('()' .. pattern) do
            if pos < min then
                min = pos
                a = options[pattern] or num
            end
            if pos > max then
                max = pos
                b = options[pattern] or num
            end
        end
    end

    sum = tonumber(a .. b) + sum
end

print(sum)
