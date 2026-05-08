local c_num = require("c_number_types")
local deep_compare = require("fast_deep_compare")

--[[
Our CN runtime state. This exists as nested tables, each corresponding
to a main part of our CN runtime that we're implementing in Lua:

- Error Stack: Stack of errors that users can push/pop to ensure helpful error messaging
- Frames: Holds any allocations that must persist for the duration of the frame (right now, the
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
    globals = {},
    locals = {}, -- Proxy table
    frames = {},
    ghost_state = {},
    spec_mode = {
        PRE  = 1,
        POST = 2,
        LOOP = 3,
        STATEMENT = 4,
        C_ACCESS = 5,
        NON_SPEC = 6
    },
    inline = {},
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

        -- c types sizeof
        sizeof = {
            array = {}
        },

        -- c loop checks
        initialise_loop_ownership_state = {},
        loop_put_back_ownership = {},

        -- c builtins
        fls = {},
        flsl = {}
    },
    map_def = {},
}

local frames = cn.frames
local C = cn.c

function cn.assert(cond, spec_mode)
    C.assert(cond, spec_mode)
end

--[[
CN MAPS
--]]

local __cnmapmt = {
    __index = function(self, k)
        return self.__default__
    end
}
function cn.map_def(def)
    if def == nil then return {} end
    return setmetatable({ __default__ = def }, __cnmapmt)
end

--[[
ERROR HANDLING
--]]

function cn.error_stack.push(msg)
    C.update_error_msg_info(msg)
end

function cn.error_stack.pop()
    C.pop_msg_info()
end

function cn.error_stack.dump()
    C.dump_error_msgs();
end

--[[
FRAMES
--]]

function frames.push_function()
    frames[#frames + 1] = {}
    C.ghost_state_depth_incr()
end

function frames.pop_function()
    C.ghost_state_depth_decr()
    C.postcondition_leak_check()
    frames[#frames] = nil
end

function frames.push_loop()
    frames[#frames + 1] = {}
end

function frames.pop_loop()
    frames[#frames] = nil
end

--[[
OWNERSHIP GHOST STATE
--]]

function cn.ghost_state.get_or_put_ownership(mode, base_addr, size, loop_ownership)
    if loop_ownership == nil then
        C.get_or_put_ownership(mode, base_addr, size, 0)
    else
        C.get_or_put_ownership(mode, base_addr, size, loop_ownership)
    end
end

function cn.ghost_state.stack_depth_incr()
    return C.ghost_state_depth_incr()
end

function cn.ghost_state.stack_depth_decr()
    return C.ghost_state_depth_decr()
end

function cn.ghost_state.postcondition_leak_check()
    C.postcondition_leak_check();
end

function C.sizeof.array(array_type, array_size)
    return C.sizeof[array_type] * array_size
end

--[[
@Saljuk TODO: Consider adding a flag to enable this

This makes it easy for us to generate Lua functions within nested tables 
since we don't have  to generate the intermediate tables. But it's gross, and makes it
so that typos no longer lead to errors but create new tables. 

It might be useful to have for a 'final' version since it makes the generation
slightly cleaner. For now, keep it disabled.
]]--

--[[
This allows us to set and get locals using cn.locals.X = Y instead of the more
verbose function calls (i.e. cn.locals.set/get_local())
]]--
setmetatable(cn.locals, {
    -- support assignments
    __newindex = function(_, key, value)
        frames[#frames][key] = value
    end,

    -- support lookups
    __index = function(_, key)
        return frames[#frames][key]
    end,

    -- support iteration over locals
    __pairs = function(_)
        return next, frames[#frames]
    end
})

--[[ 
Setup an environment where core functions can be easily used 'globally'

@saljuk TODO Consider porting over more things to the environment paradigm
so that we can just call error_stack.push() instead of cn.error_stack.push()
]] --
local is_c_true = function(val) return (val ~= 0 and val ~= nil and val ~= false) end
local ptr_type_eq = function(a, b) return (a == b) end
local get_or_put_ownership = cn.ghost_state.get_or_put_ownership
local core = {
    c_num = c_num,
    equals = deep_compare,
    is_null = function(p) return (p == nil or p == 0) end,
    ptr_eq = ptr_type_eq,
    addr_eq = ptr_type_eq, --@saljuk $NOTE: Not supported
    owned = function(mode, base_addr, size, loop_ownership, reader)
        get_or_put_ownership(mode, base_addr, size, loop_ownership)
        return reader(base_addr)
    end,
    map_get = function(m, k, def) return m[k] or def end,

    member_shift = function(base_addr, offset)
        return (base_addr + offset)
    end,
      
    array_shift = function(base_addr, offset, size)
        return (base_addr + (offset * size))
    end,

    bool_and = 
        function(a, b) 
            local a_ctrue = is_c_true(a)
            local b_ctrue = is_c_true(b)
            return (a_ctrue and b_ctrue)
        end,
    bool_or = 
        function(a, b) 
            local a_ctrue = is_c_true(a)
            local b_ctrue = is_c_true(b)
            return (a_ctrue or b_ctrue)
        end,
    implies =
        function(a, b) 
            local a_ctrue = is_c_true(a)
            local b_ctrue = is_c_true(b)
            return ((not a_ctrue) or b_ctrue)
        end,
}

cn.env = setmetatable(core, { __index = _G })

function C.generate_get_array(array_type, array_size)
    return function (base_address)
        local arr = {}
        local i = 0 -- note: we follow 'zero based indexing'
        while (i <= array_size) do
            arr[i] = 
                C["get_" .. array_type]
                (core.array_shift(base_address, i, C.sizeof[array_type]))
            i = i + 1
        end
        return arr
    end
end

return cn
