local cn = require("lua_cn_runtime_core")

function cn.arrow_access_1.precondition()

end

function cn.arrow_access_1.push_frame()
    cn.frames.push_function()
end

function cn.asserts.inst32()
    cn.error_stack.push("  /*@ assert (origin.x == 0i32); @*/ // -- member\n      ^~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:9:7-33")
    cn.assert(cn.equals(read_origin0, 0), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.asserts.inst31()
    cn.error_stack.push("  /*@ assert (p->x == 0i32); @*/   // Arrow access\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:13:7-29")
    cn.assert(cn.equals(deref_read_p00, 0), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.asserts.inst32()
    cn.error_stack.push("  /*@ assert ((*p).x == 0i32); @*/ // ... desugared as this\n      ^~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:14:7-31")
    cn.assert(cn.equals(deref_read_p10, 0), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.asserts.inst45()
    cn.error_stack.push("  /*@ assert (q->y == 7i32); @*/\n      ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:16:7-29")
    cn.assert(cn.equals(deref_read_q00, 7), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.arrow_access_1.postcondition()

end

function cn.arrow_access_2.precondition()
    cn.error_stack.push("  take Or = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:22:8:")
    cn.error_stack.pop()
    cn.error_stack.push("  origin->y == 0i32;\n  ^~~~~~~~~~~~~~~~~~ ./tests/cn/arrow_access.c:23:3-21")
    cn.assert(cn.equals(Or, 0), cn.spec_mode.PRE)
    cn.error_stack.pop()
end

function cn.arrow_access_2.push_frame(origin_addr)
    cn.frames.push_function()
    cn.frames.set_local("origin", cn.c.get_pointer(origin_addr))
end

function cn.arrow_access_2.postcondition()

end

