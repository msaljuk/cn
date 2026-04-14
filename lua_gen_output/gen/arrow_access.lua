local cn = require("lua_cn_runtime_core")

_ENV = cn.env

function cn.arrow_access_1.precondition()

end

function cn.arrow_access_1.push_frame()
    cn.frames.push_function()
end

function cn.inline.instance0(origin)
    local read_origin0 = cn.c.get_s(origin)
    cn.error_stack.push("  /*@ assert (origin.x == 0i32); @*/ // -- member\n      ^~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:7-33")
    cn.assert(cn.equals(read_origin0.x, 0), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.inline.instance1(p)
    local read_p0 = cn.c.get_pointer(p)
    local deref_read_p00 = cn.c.get_s(read_p0)
    cn.error_stack.push("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:7-29")
    cn.assert(cn.equals(deref_read_p00.x, 0), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.inline.instance2(p)
    local read_p1 = cn.c.get_pointer(p)
    local deref_read_p10 = cn.c.get_s(read_p1)
    cn.error_stack.push("  /*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n      ^~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:7-31")
    cn.assert(cn.equals(deref_read_p10.x, 0), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.inline.instance3(q)
    local read_q0 = cn.c.get_pointer(q)
    local deref_read_q00 = cn.c.get_s(read_q0)
    cn.error_stack.push("  /*@ assert (q->y == 7i32); @*/\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:7-29")
    cn.assert(cn.equals(deref_read_q00.y, 7), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.inline.instance4(p, q)
    local read_q1 = cn.c.get_pointer(q)
    local deref_read_q10 = cn.c.get_s(read_q1)
    local read_p2 = cn.c.get_pointer(p)
    local deref_read_p20 = cn.c.get_s(read_p2)
    cn.error_stack.push("  /*@ assert (q->y == p->y); @*/\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:17:7-29")
    cn.assert(cn.equals(deref_read_q10.y, deref_read_p20.y), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.arrow_access_1.postcondition()

end

function cn.arrow_access_2.precondition()
    cn.error_stack.push("  take Or = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:23:8:")
    cn.locals.Or = cn.owned(cn.spec_mode.PRE, cn.locals.origin, cn.c.sizeof.s, nil, cn.c.get_s)
    cn.error_stack.pop()
    cn.error_stack.push("  origin->y == 0i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:24:3-21")
    cn.assert(cn.equals(cn.locals.Or.y, 0), cn.spec_mode.PRE)
    cn.error_stack.pop()
end

function cn.arrow_access_2.push_frame(origin)
    cn.frames.push_function()
    cn.locals.origin = origin
end

function cn.inline.instance5(origin)
    local read_origin1 = cn.c.get_pointer(origin)
    local deref_read_origin10 = cn.c.get_s(read_origin1)
    cn.error_stack.push("  /*@ assert (origin->y == 7i32); @*/\n      ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:32:7-34")
    cn.assert(cn.equals(deref_read_origin10.y, 7), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.arrow_access_2.postcondition()
    cn.error_stack.push("  take Or_ = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:26:8:")
    cn.locals.Or_ = cn.owned(cn.spec_mode.POST, cn.locals.origin, cn.c.sizeof.s, nil, cn.c.get_s)
    cn.error_stack.pop()
    cn.error_stack.push("  origin->y == 7i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:27:3-21")
    cn.assert(cn.equals(cn.locals.Or_.y, 7), cn.spec_mode.POST)
    cn.error_stack.pop()
    cn.error_stack.push("  (*origin).y == 7i32;\n  ^~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:28:3-23")
    cn.assert(cn.equals(cn.locals.Or_.y, 7), cn.spec_mode.POST)
    cn.error_stack.pop()
end

function cn.main.precondition()

end

function cn.main.push_frame()
    cn.frames.push_function()
end

function cn.main.postcondition(__cn_ret)

end

return cn
