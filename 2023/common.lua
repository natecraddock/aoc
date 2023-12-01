local common = {}

function common.readlines(path, fn)
    fn = fn or function(x) return x end

    local tbl = {}
    for line in io.lines(path) do
        tbl[#tbl + 1] = fn(line)
    end
    return tbl
end

return common
