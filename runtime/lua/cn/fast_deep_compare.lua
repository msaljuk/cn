--- deeply compare two objects
--- Original code sourced from: https://gist.github.com/sapphyrus/fd9aeb871e3ce966cc4b0b969f62f539
--- MIT License, Copyright (c) 2022 sapphyrus
local function deep_equals(o1, o2, ignore_mt)
    -- same object
    if o1 == o2 then return true end

    local o1Type = type(o1)
    local o2Type = type(o2)

    ---@saljuk MODIFICATION: Support implicit casting of booleans to numbers
    if o1Type == "boolean" and o2Type == "number" then
        o1 = o1 and 1 or 0
        return o1 == o2
    elseif o1Type == "number" and o2Type == "boolean" then
        o2 = o2 and 1 or 0
        return o1 == o2
    end

    --- different type
    if o1Type ~= o2Type then return false end
    --- same type but not table, already compared above
    if o1Type ~= 'table' then return false end

    -- use metatable method
    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    -- iterate over o1
    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or deep_equals(value1, value2, ignore_mt) == false then
            return false
        end
    end

    --- check keys in o2 but missing from o1
    for key2, _ in pairs(o2) do
        if o1[key2] == nil then return false end
    end
    return true
end

return deep_equals