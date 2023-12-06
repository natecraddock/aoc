local common = require 'common'

local sections = {}

local data = {}
for line in io.lines('data/05.txt') do
    data[#data + 1] = line
    if line == '' then
        sections[#sections + 1] = data
        data = {}
    end
end
sections[#sections + 1] = data

local seeds = sections[1][1]:match('seeds: (.*)'):collect('%d+', tonumber)

local maps = {}
for i = 2, #sections do
    local ranges = {}
    for _, mapping in ipairs(sections[i]) do
        local d, s, r = mapping:match '(%d+) (%d+) (%d+)'
        if d then
            d, s, r = tonumber(d), tonumber(s), tonumber(r)
            ranges[#ranges + 1] = { d = d, s = s, r = r }
        end
    end

    maps[#maps + 1] = function(num)
        -- handle ranges for part 2
        if type(num) == 'table' then

            return {}
        end

        for _, range in ipairs(ranges) do
            if range.s <= num and num < range.s + range.r then
                return range.d + (num - range.s)
            end
        end

        return num
    end
end

local min = math.maxinteger
for _, seed in ipairs(seeds) do
    for _, map in ipairs(maps) do
        seed = map(seed)
    end
    if seed < min then min = seed end
end
print(min)

local ranges = {}
for i = 1, #seeds, 2 do
    ranges[#ranges + 1] = { s = seeds[i], e = seeds[i + 1] - 1 }
end

min = math.maxinteger
for _, map in ipairs(maps) do
    local new_ranges = {}

    for _, range in ipairs(ranges) do
        local rs = map(range)
        for _, r in ipairs(rs) do
            if r.s < min then
                min = r.s
            end
            new_ranges[#new_ranges + 1] = r
        end
    end

    ranges = new_ranges
end
print(min)
