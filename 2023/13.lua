local common = require 'common'

local function patterns()
    local iter = io.lines('data/13.txt')

    return function()
        if not iter then return nil end

        local pattern
        local line = iter()
        while line and line ~= '' do
            pattern = pattern or {}
            table.insert(pattern, line)
            line = iter()
        end

        if not line then iter = nil end
        return pattern
    end
end

local function test_horizontal(pattern, a, b)
    while a >= 1 and b <= #pattern do
        if pattern[a] ~= pattern[b] then return false end
        a = a - 1
        b = b + 1
    end
    return true
end

local function col(pattern, index)
    local s = ''
    for i = 1, #pattern do
        s = s .. pattern[i]:sub(index, index)
    end
    return s
end

local function test_vertical(pattern, a, b)
    while a >= 1 and b <= #pattern[1] do
        if col(pattern, a) ~= col(pattern, b) then return false end
        a = a - 1
        b = b + 1
    end
    return true
end

local sum = 0
for pattern in patterns() do
    -- horizontal
    for i = 1, #pattern - 1 do
        if pattern[i] == pattern[i + 1] then
            -- possible reflection point
            if test_horizontal(pattern, i, i + 1) then
                sum = sum + (i * 100)
                goto continue
            end
        end
    end

    -- vertical
    for i = 1, #pattern[1] - 1 do
        if col(pattern, i) == col(pattern, i + 1) then
            if test_vertical(pattern, i, i + 1) then
                sum = sum + i
                break
            end
        end
    end

    ::continue::
end
print(sum)

-- returns if a and b are equal considering the possiblity of a smudge
local function smudgeql(a, b)
    if a == b then return true, false end
    local differences = 0
    for i = 1, #a do
        if a:sub(i, i) ~= b:sub(i, i) then differences = differences + 1 end
    end
    return differences == 1, differences == 1
end

local function test_horizontal_smudge(pattern, a, b, smudge)
    while a >= 1 and b <= #pattern do
        local eql, s = smudgeql(pattern[a], pattern[b])

        -- if already smudged then this cannot be a match!
        if smudge and s then return false end
        smudge = smudge or s

        if not eql then return false end
        a = a - 1
        b = b + 1
    end
    return smudge
end

local function test_vertical_smudge(pattern, a, b, smudge)
    while a >= 1 and b <= #pattern[1] do
        local eql, s = smudgeql(col(pattern, a), col(pattern, b))
        if smudge and s then return false end
        smudge = smudge or s

        if not eql then return false end
        a = a - 1
        b = b + 1
    end
    return smudge
end


-- part 2
sum = 0
for pattern in patterns() do
    -- horizontal
    for i = 1, #pattern - 1 do
        local eql, smudge = smudgeql(pattern[i], pattern[i + 1])
        if eql then
            if test_horizontal_smudge(pattern, i - 1, i + 2, smudge) then
                sum = sum + (i * 100)
                goto continue
            end
        end
    end

    -- vertical
    for i = 1, #pattern[1] - 1 do
        local eql, smudge = smudgeql(col(pattern, i), col(pattern, i + 1))
        if eql then
            if test_vertical_smudge(pattern, i - 1, i + 2, smudge) then
                sum = sum + i
                break
            end
        end
    end

    ::continue::
end
print(sum)
