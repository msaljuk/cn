local cn = require("lua_cn_runtime_core")

function cn.arrow_access_1.precondition()

end

function cn.arrow_access_1.push_frame()
    cn.frames.push_function()
end

function cn.arrow_access_1.postcondition()

end

function cn.arrow_access_2.precondition()
    cn.error_stack.push("  take Or = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:22:8:")
    cn.error_stack.pop()
end

function cn.arrow_access_2.push_frame(origin_addr)
    cn.frames.push_function()
    cn.frames.set_local("origin", cn.c.get_pointer(origin_addr))
end

function cn.arrow_access_2.postcondition()

end

function cn.arrow_access_3_dummy_example_by_saljuk.precondition()
    cn.error_stack.push("  take Or = RW<struct s>(origin);\n       ^./tests/cn/arrow_access.c:37:8:")
    cn.error_stack.pop()
end

function cn.arrow_access_3_dummy_example_by_saljuk.push_frame(origin_addr, x_addr, y_addr)
    cn.frames.push_function()
    cn.frames.set_local("origin", cn.c.get_pointer(origin_addr))
    cn.frames.set_local("x", cn.c.get_integer(x_addr))
    cn.frames.set_local("y", cn.c.get_pointer(y_addr))
end

function cn.arrow_access_3_dummy_example_by_saljuk.postcondition()

end

