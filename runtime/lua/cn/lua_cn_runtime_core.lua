local deep_compare = require("fast_deep_compare")

--[[
Our CN runtime state. This exists as nested tables, each corresponding
to a main part of our CN runtime that we're implementing in Lua:

- Error Stack: Stack of errors that users can push/pop to ensure helpful error messaging
- Locals: Holds any allocations that must persist for the duration of the frame (right now, the
  main usage is any CN pre condition variables that are later used during the post condition). Each
  frame is keyed to the current stack depth, meaning when the frame is popped at the end of the function,
  all frame-specific variables are easily cleaned up with GC. I initially also thought I'd use this to map
  C vars/addresses into CN types (something we discussed in our last call) but I haven't needed to do that...yet.
- Ghost state: Cororallary to the ownership-ghost-state
- Current Stack Depth: Self explanatory
- Spec Mode: ENUM style mapping of spec modes for usage later

NOTE: This file crafts the core runtime under the CN table. Later on, we add to this table when we
generate our file specific Lua runtime code (in this case append.cn.lua). To the outside consumer (i.e. C),
the entire thing falls under cn.
--]]

local cn = {
    error_stack = {},
    locals = {},
    ghost_state = {},
    spec_mode = {
        PRE  = 1,
        POST = 2,
        LOOP = 3,
        STATEMENT = 4,
        C_ACCESS = 5,
        NON_SPEC = 6
    },
    equals = deep_compare,
    c = {
        -- c asserts
        assert = {},

        -- c ghost state
        add_to_ghost_state = {},
        remove_from_ghost_state = {},
        get_or_put_ownership = {},
        ghost_state_depth_incr = {},
        ghost_state_depth_decr = {},
        postcondition_leak_check = {},

        -- c error handling
        update_error_msg_info = {},
        pop_msg_info = {},
        dump_error_msgs = {},

        -- c types reading
        get_bool = {},
        get_char = {},
        get_integer = {},
        get_float = {},
        get_pointer = {},

        -- c loop checks
        initialise_loop_ownership_state = {},
        loop_put_back_ownership = {},
    }
}

function cn.assert(cond, spec_mode)
    cn.c.assert(cond, spec_mode);
end

--[[
ERROR HANDLING
--]]

function cn.error_stack.push(msg)
    cn.c.update_error_msg_info(msg)
end

function cn.error_stack.pop()
    cn.c.pop_msg_info()
end

function cn.error_stack.dump()
    cn.c.dump_error_msgs();
end

--[[
LOCALS
--]]

function cn.locals.push_function()
    cn.locals[#cn.locals + 1] = {}
    cn.c.ghost_state_depth_incr()
end

function cn.locals.pop_function()
    cn.c.ghost_state_depth_decr()
    cn.c.postcondition_leak_check()
    cn.locals[#cn.locals] = nil
end

function cn.locals.push_loop()
    cn.locals[#cn.locals + 1] = {}
end

function cn.locals.pop_loop()
    cn.locals[#cn.locals] = nil
end

function cn.locals.get_current_frame()
    return cn.locals[#cn.locals]
end

function cn.locals.set_local(name, value)
    cn.locals.get_current_frame()[name] = value
end

function cn.locals.get_local(name)
    return cn.locals.get_current_frame()[name]
end

--[[
OWNERSHIP GHOST STATE
--]]

function cn.ghost_state.get_or_put_ownership(mode, base_addr, size, loop_ownership)
    if loop_ownership == nil then
        cn.c.get_or_put_ownership(mode, base_addr, size, 0)
    else
        cn.c.get_or_put_ownership(mode, base_addr, size, loop_ownership)
    end
end

function cn.ghost_state.stack_depth_incr()
    return cn.c.ghost_state_depth_incr()
end

function cn.ghost_state.stack_depth_decr()
    return cn.c.ghost_state_depth_decr()
end

function cn.ghost_state.postcondition_leak_check()
    cn.c.postcondition_leak_check();
end

function cn.owned(mode, base_addr, size, loop_ownership, reader)
    cn.ghost_state.get_or_put_ownership(mode, base_addr, size, loop_ownership)
    return reader(base_addr)
end

function cn.member_shift(base_addr, offset)
    return (base_addr + offset)
end

--[[
@Saljuk TODO: Get rid of this. This makes it easy for us
to generate Lua functions within nested tables since we don't have 
to generate the intermediate tables. But it's gross, and makes it
so that typos no longer lead to errors but create new tables. Come
up with a more elegant solution (possibly involving analyzing all the
generated functions and generating the nested table structure from them)
]]--
local mt = {}
mt.__index = function(t, k)
    t[k] = setmetatable({}, mt)
    return t[k]
end
setmetatable(cn, mt)

--[[
This allows us to set and get locals using cn.locals.X = Y instead of the more
verbose function calls (i.e. cn.locals.set/get_local())
]]--
setmetatable(cn.locals, {
    -- support assignments
    __newindex = function(table, key, value)
        table.set_local(key, value)
    end,

    -- support lookups
    __index = function(table, key)
        return table.get_local(key)
    end,

    -- support iteration over locals
    __pairs = function(table)
        local real_table = table.get_current_frame()
        return next, real_table, nil
    end
})

--[[ 
Setup an environment where builtins can be easily used 'globally'

@saljuk TODO Consider porting over more things to the environment paradigm
so that we can just call error_stack.push() instead of cn.error_stack.push()
]] --
local builtins = {
    is_null = function(p) return (p == nil) end
}
cn.env = setmetatable({}, {
    __index = function(_, k) 
        return builtins[k] or _G[k] 
    end 
})

return cn
