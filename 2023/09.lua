local common = require 'common'

local histories = common.readlines('data/09.txt', function(line)
    return line:collect('[-%d]+', tonumber)
end)

local function get_differences(nums)
    local all_zero = true
    local differences = {}
    for i = 1, #nums - 1 do
        local difference = nums[i + 1] - nums[i]
        table.insert(differences, difference)

        if difference ~= 0 then
            all_zero = false
        end
    end
    return differences, all_zero
end

local function next_value(nums)
    local differences, all_zero = get_differences(nums)
    if all_zero then
        return nums[#nums]
    else
        return next_value(differences) + nums[#nums]
    end
end

local function first_value(nums)
    local differences, all_zero = get_differences(nums)
    if all_zero then
        return nums[1]
    else
        return nums[1] - first_value(differences)
    end
end

local sum_next = 0
local sum_first = 0
for _, history in ipairs(histories) do
    sum_next = sum_next + next_value(history)
    sum_first = sum_first + first_value(history)
end
print(sum_next)
print(sum_first)
