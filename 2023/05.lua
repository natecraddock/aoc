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
    local mappings = {}
    for _, mapping in ipairs(sections[i]) do
        local d, s, r = mapping:match '(%d+) (%d+) (%d+)'
        if d then
            d, s, r = tonumber(d), tonumber(s), tonumber(r)
            mappings[#mappings + 1] = { d = d, s = s, r = r }
        end
    end

    maps[#maps + 1] = function(num)
        -- handle ranges for part 2
        if type(num) == 'table' then
            local all = {}

            for _, mapping in ipairs(mappings) do
                local new = {}
                while #num > 0 do
                    local r = table.remove(num)

                    local before = { s = r.s , e = math.min(r.e, mapping.s) }
                    local inner = { s = math.max(r.s, mapping.s), e = math.min(mapping.s + mapping.r, r.e) }
                    local after = { s = math.max(mapping.s + mapping.r, r.s), e = r.e }

                    if before.e > before.s then table.insert(new, before) end
                    if inner.e > inner.s then table.insert(all, { s = inner.s - mapping.s + mapping.d, e = inner.e - mapping.s + mapping.d }) end
                    if after.e > after.s then table.insert(new, after) end
                end
                num = new
            end

            for _, n in ipairs(num) do
                table.insert(all, n)
            end

            return all
        end

        for _, mapping in ipairs(mappings) do
            if mapping.s <= num and num < mapping.s + mapping.r then
                return mapping.d + (num - mapping.s)
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
    ranges[#ranges + 1] = { s = seeds[i], e = seeds[i] + (seeds[i + 1] - 1) }
end

min = math.maxinteger
for _, rs in ipairs(ranges) do
    -- convert it to a list, because we expect each range to eventually split into many
    rs = { rs }

    -- apply each map to the list of ranges
    for _, map in ipairs(maps) do
        rs = map(rs)
    end

    -- find the smallest starting for the range
    for _, r in ipairs(rs) do
        if r.s < min then min = r.s end
    end
end
print(min)
