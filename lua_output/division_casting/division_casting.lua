local cn = require("lua_cn_runtime_core")

cn.divison = {}

function cn.divison.precondition(x, y)
    cn.frames.set_local("x", cn.c.get_integer(x))
    cn.frames.set_local("y", cn.c.get_integer(y))

    cn.error_stack.push("/*@ requires y > 0i32;\n             ^~~~~~~~~ ./tests/cn/division_casting.c:8:14-23")
    cn.assert(cn.frames.get_local("y") > 0, cn.spec_mode.PRE);
    cn.error_stack.pop()

    print("Precondition Passed in Lua")
end

function cn.divison.postcondition(ret)
    cn.frames.set_local("return", cn.c.get_integer(ret))

    cn.error_stack.push("    ensures return == x/(u32)y; @*/\n            ^~~~~~~~~~~~~~~~~~~ ./tests/cn/division_casting.c:9:13-32")
    cn.assert(cn.frames.get_local("return") == (cn.frames.get_local("x") // cn.frames.get_local("y")), cn.spec_mode.POST);
    cn.error_stack.pop()

    print("Precondition Passed in Lua")
end

return cn