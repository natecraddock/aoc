local common = require 'common'

local cards = common.readlines('data/04.txt', function(line)
    local win, have = line:match 'Card +%d+: (.*) | (.*)'

    -- split on spaces
    win = win:collect('%d+', tonumber)
    have = have:collect('%d+', tonumber)

    local winners = {}
    for _, num in ipairs(win) do
        winners[num] = true
    end

    return { win = winners, have = have }
end)

local sum = 0
for _, card in ipairs(cards) do
    local count = 0
    for _, num in ipairs(card.have) do
        if card.win[num] then count = count + 1 end
    end

    if count > 0 then sum = sum + (2 ^ (count - 1)) end
end
print(math.floor(sum))

local nums = {}
for i = 1, #cards do nums[i] = 1 end
for i, num in pairs(nums) do
    local card = cards[i]
    local count = 0
    for _, num in ipairs(card.have) do
        if card.win[num] then count = count + 1 end
    end

    for j = i + 1, i + count do nums[j] = nums[j] + nums[i] end
end

sum = 0
for i, num in pairs(nums) do
    sum = sum + num
end
print(sum)
