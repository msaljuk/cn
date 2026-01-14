local cn = require("lua_cn_runtime_core")

-- C calls
cn.c.read_s = {}

-- Instrumented Function Tables
cn.arrow_access_1 = {}
cn.arrow_access_2 = {}

--[[
Asserts
--]]

cn.arrow_access_1.assert = {}

function cn.arrow_access_1.assert.a(origin)
    local m1, s1, m2, s2, size = cn.c.read_s(origin)

    cn.error_stack.push("/*@ assert (origin.x == 0i32); @*/ // -- member\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:6-35")
    local x = cn.c.get_integer(m1);
    cn.assert(x == 0, cn.spec_mode.STATEMENT);
    cn.error_stack.pop()
end

function cn.arrow_access_1.assert.b(p)
    local m1, s1, m2, s2, size = cn.c.read_s(p)

    cn.error_stack.push("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n     ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:6-31")
    local x = cn.c.get_integer(m1);
    cn.assert(x == 0, cn.spec_mode.STATEMENT);
    cn.error_stack.pop()
end

function cn.arrow_access_1.assert.c(q)
    local m1, s1, m2, s2, size = cn.c.read_s(q)

    cn.error_stack.push("/*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n     ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:6-33")
    local x = cn.c.get_integer(m1);
    cn.assert(x == 0, cn.spec_mode.STATEMENT);
    cn.error_stack.pop()
end

function cn.arrow_access_1.assert.d(q)
    local m1, s1, m2, s2, size = cn.c.read_s(q)

    cn.error_stack.push("/*@ assert (q->y == 7i32); @*/\n     ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:6-31")
    local y = cn.c.get_integer(m2);
    cn.assert(y == 7, cn.spec_mode.STATEMENT);
    cn.error_stack.pop()
end

--[[
Pre/Post conditions
--]]

function cn.arrow_access_2.precondition(origin)
    cn.frames.set_local("Or", origin);

    local m1, s1, m2, s2, size = cn.c.read_s(cn.frames.get_local("Or"));

    cn.error_stack.push("take Or = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:22:8:")
    cn.ghost_state.get_or_put_ownership(cn.spec_mode.PRE, cn.frames.get_local("Or"), size)
    cn.error_stack.pop()

    cn.error_stack.push("origin->y == 0i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:23:3-21")
    local y = cn.c.get_integer(m2)
    cn.assert(y == 0, cn.spec_mode.PRE)
    cn.error_stack.pop()

    print("Precondition Passed in Lua")
end

function cn.arrow_access_2.postcondition()
    local m1, s1, m2, s2, size = cn.c.read_s(cn.frames.get_local("Or"));

    cn.error_stack.push("take Or_ = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:25:8:")
    cn.ghost_state.get_or_put_ownership(cn.spec_mode.POST, cn.frames.get_local("Or"), size)
    cn.error_stack.pop()

    cn.error_stack.push("origin->y == 7i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:26:3-21")
    local y_1 = cn.c.get_integer(m2);
    cn.assert(y_1 == 7, cn.spec_mode.POST)
    cn.error_stack.pop()

    cn.error_stack.push("(*origin).y == 7i32;\n  ^~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:27:3-23")
    local y_2 = cn.c.get_integer(m2);
    cn.assert(y_2 == 7, cn.spec_mode.POST)
    cn.error_stack.pop()

    print("Postcondition Passed in Lua")
end

return cn