local cn = require("lua_cn_runtime_core")

--[[
CN spec
--]]

local function Is_Known_Binop(ret)
    return (ret == cn.frames.get_local("f1") or ret == cn.frames.get_local("f2"))
end

--[[
Pre/Post conditions
--]]

cn.get_int_binop = {}

function cn.get_int_binop.postcondition(ret, f1, f2)
    cn.frames.set_local("f1", f1);
    cn.frames.set_local("f2", f2);

    cn.error_stack.push("/*@ ensures take X = Is_Known_Binop (return); @*/\n                 ^./tests/cn/fun_ptr_extern.c:34:18:")
    cn.frames.set_local("X", Is_Known_Binop(ret))
    cn.assert(cn.frames.get_local("X"), cn.spec_mode.POST)
    cn.error_stack.pop()

    print("Postcondition Passed in Lua")
end

return cn
