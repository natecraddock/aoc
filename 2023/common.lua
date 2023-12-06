local common = {}

function common.readlines(path, fn)
    fn = fn or function(x) return x end

    local tbl = {}
    for line in io.lines(path) do
        tbl[#tbl + 1] = fn(line)
    end
    return tbl
end

function table.len(tbl)
    local len = 0
    for _ in pairs(tbl) do len = len + 1 end
    return len
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
