local common = require 'common'

local find = function(list, value)
    for i, v in ipairs(list) do
        if v == value then return i end
    end
    return nil
end

-- equal values
local eql = function(a, b)
    for _, v in pairs(a) do
        local pos = find(b, v)
        if pos then
            table.remove(b, pos)
        else
            return false
        end
    end
    return #b == 0
end

local data = common.readlines('data/07.txt', function(line)
    local hand_str, bid = line:match('(.+) (.+)')

    local hand = {}
    for i = 1, #hand_str do
        local card = hand_str:sub(i, i)
        if hand[card] then
            hand[card] = hand[card] + 1
        else
            hand[card] = 1
        end
    end

    -- part 2
    if hand['J'] and hand['J'] < 5 then
        local max = { val = 0 }
        for k, v in pairs(hand) do
            if k ~= 'J' and v > max.val then
                max = { val = v, card = k }
            end
        end
        hand[max.card] = hand[max.card] + hand['J']
        hand['J'] = nil
    end

    local type = 1
    if eql(hand, { 5 }) then
        type = 7
    elseif eql(hand, { 4, 1 }) then
        type = 6
    elseif eql(hand, { 3, 2 }) then
        type = 5
    elseif eql(hand, { 3, 1, 1 }) then
        type = 4
    elseif eql(hand, { 2, 2, 1 }) then
        type = 3
    elseif eql(hand, { 2, 1, 1, 1 }) then
        type = 2
    end

    return { str = hand_str, type = type, bid = tonumber(bid) }
end)

local order = { A = 14, K = 13, Q = 12, J = 0, T = 10 }
local function cmp(a, b)
    a = tonumber(a) or order[a]
    b = tonumber(b) or order[b]
    if a == b then return nil end
    return a < b
end

table.sort(data, function(a, b)
    if a.type == b.type then
        for i = 1, 5 do
            local o = cmp(a.str:sub(i, i), b.str:sub(i, i))
            if o ~= nil then
                return o
            end
        end
    else
        return a.type < b.type
    end
end)

local sum = 0
for i, hand in ipairs(data) do
    print(i, hand.str, hand.type)
    sum = sum + (i * hand.bid)
end
print(sum)
