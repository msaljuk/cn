local cn = require("lua_cn_runtime_core")

-- CN spec

local function bw_compl_expr()
    local x = 2;
    return (~(x+x) == -5);
end

--[[
Asserts
--]]

cn.main = {
    assert = {}
}

function cn.main.assert.a()
    cn.error_stack.push("/*@ assert (~0i32 == -1i32); @*/\n       ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/bitwise_compl.c:10:8-35")
    cn.assert(~0 == -1, cn.spec_mode.STATEMENT);
    cn.error_stack.pop()
end

function cn.main.assert.b()
    cn.error_stack.push("    /*@ assert (bw_compl_expr()); @*/\n       ^~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/bitwise_compl.c:11:8-36")
    cn.assert(bw_compl_expr(), cn.spec_mode.STATEMENT);
    cn.error_stack.pop()
end

function cn.main.assert.c(y)
    cn.error_stack.push("    /*@ assert(y == -1i32); @*/\n       ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/bitwise_compl.c:14:8-30")
    local y_val = cn.c.get_integer(y)
    cn.assert(y_val == -1, cn.spec_mode.STATEMENT);
    cn.error_stack.pop()
end

return cn