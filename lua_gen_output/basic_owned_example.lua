local cn = require("lua_cn_runtime_core")

function cn.acquire_random_integer_pointer.precondition()
    cn.error_stack.push("  take Or = RW<int>(random);\n       ^./lua_gen_output/basic_owned_example.c:4:8:")
    cn.frames.set_local("Or", cn.owned(cn.frames.get_local("random"), cn.spec_mode.PRE, 0))
    cn.error_stack.pop()
    cn.error_stack.push("  *random == 0i32;\n  ^~~~~~~~~~~~~~~~ ./lua_gen_output/basic_owned_example.c:5:3-19")
    cn.assert(cn.equals(cn.c.get_integer(cn.frames.get_local("Or")), 0), cn.spec_mode.PRE)
    cn.error_stack.pop()
end

function cn.acquire_random_integer_pointer.push_frame(random_addr)
    cn.frames.push_function()
    cn.frames.set_local("random", cn.c.get_pointer(random_addr))
end

function cn.acquire_random_integer_pointer.postcondition()

end

