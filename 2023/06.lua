local common = require 'common'

local data = common.readlines('data/06.txt')
local times = data[1]:collect('%d+', tonumber)
local distances = data[2]:collect('%d+', tonumber)

-- part 1
local sum = 1
for race = 1, #times do
    local t, d = times[race], distances[race]

    local num_wins = 0
    for hold = 1, t do
        local traveled = (t - hold) * hold
        if traveled > d then
            num_wins = num_wins + 1
        end
    end

    sum = sum * num_wins
end
print(sum)

-- part 2

local t, d = '', ''
for i = 1, #times do
    t = t .. times[i]
    d = d .. distances[i]
end
t, d = tonumber(t), tonumber(d)

local num_wins = 0
for hold = 1, t do
    local traveled = (t - hold) * hold
    if traveled > d then
        num_wins = num_wins + 1
    end
    if hold % 1000 == 0 then print(hold) end
end
print(num_wins)
