local cn = require("lua_cn_runtime_core")

function cn.IntList_append.precondition()
    cn.error_stack.push("/*@ requires take L1 = IntList(xs);\n                  ^./tests/cn/append.c:35:19:")
    cn.error_stack.pop()
    cn.error_stack.push("             take L2 = IntList(ys);\n                  ^./tests/cn/append.c:36:19:")
    cn.error_stack.pop()
end

function cn.IntList_append.push_frame(xs_addr, ys_addr, actual_struct_param_addr)
    cn.frames.push_function()
    cn.frames.set_local("xs", cn.c.get_pointer(xs_addr))
    cn.frames.set_local("ys", cn.c.get_pointer(ys_addr))
    cn.frames.set_local("actual_struct_param", cn.c.peek_int_list(actual_struct_param_addr))
end

function cn.IntList_append.postcondition()

end

function cn.main.precondition()

end

function cn.main.push_frame()
    cn.frames.push_function()
end

function cn.main.postcondition()

end

