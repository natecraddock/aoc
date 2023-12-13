local common = {}

function common.readlines(path, fn)
    fn = fn or function(x) return x end

    local tbl = {}
    for line in io.lines(path) do
        tbl[#tbl + 1] = fn(line)
    end
    return tbl
end

function common.gcd(a, b)
    if a == 0 then
        return b
    end
    return common.gcd(b % a, a)
end

function common.lcm(a, b)
    return (a // common.gcd(a, b)) * b
end

-- flatten one level
local function flatten(tbl)
    local t = {}
    for i = 1, #tbl do
        if type(tbl[i]) == 'table' then
            for j = 1, #tbl[i] do
                table.insert(t, tbl[i][j])
            end
        else
            table.insert(t, tbl[i])
        end
    end
    return t
end

local function get(cache, args)
    args = flatten(args)
    local node = cache
    for i = 1, #args do
        node = node.children and node.children[args[i]]
        if not node then return nil end
    end
    return node.results
end

local function put(cache, args, results)
    args = flatten(args)
    local node = cache
    local arg
    for i = 1, #args do
        arg = args[i]
        node.children = node.children or {}
        node.children[arg] = node.children[arg] or {}
        node = node.children[arg]
    end
    node.results = results
end

function common.memoize(f)
    local cache = {}

    return function(...)
        local args = {...}
        local results = get(cache, args)
        if not results then
            results = { f(...) }
            put(cache, args, results)
        end
        return table.unpack(results)
    end
end

-- monkey patch table

function table.len(tbl)
    local len = 0
    for _ in pairs(tbl) do len = len + 1 end
    return len
end

function table.new(value, size)
    local tbl = {}
    for i = 1, size do
        table.insert(tbl, value)
    end
    return tbl
end

function table.sum(tbl)
    local sum = 0
    for i = 1, #tbl do
        sum = sum + tbl[i]
    end
    return sum
end

-- monkey patch string

function string.collect(s, pattern, fn)
    local tbl = {}
    for match in s:gmatch(pattern) do
        if fn then
            tbl[#tbl + 1] = fn(match)
        else
            tbl[#tbl + 1] = match
        end
    end
    return tbl
end

function string.split(s)
end

return common
