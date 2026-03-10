local cn = require("lua_cn_runtime_core")

function cn.simple_integer.precondition()
    cn.error_stack.push("  s == 0i32;\n  ^~~~~~~~~~ ./lua_gen_output/basic_owned_example.c:4:3-13")
    cn.assert(cn.equals(cn.frames.get_local("s"), 0), cn.spec_mode.PRE)
    cn.error_stack.pop()

     print("SIMPLE INTEGER PRECOND PASSED")
end

function cn.simple_integer.push_frame(s)
    cn.frames.push_function()
    cn.frames.set_local("s", s())
end

function cn.simple_integer.postcondition()
    print("SIMPLE INTEGER POSTCOND PASSED")
end

function cn.simple_owned.precondition()
    cn.error_stack.push("  take Or = RW<struct s>(origin);\n       ^./lua_gen_output/basic_owned_example.c:17:8:")
    cn.frames.set_local("Or", cn.owned(cn.spec_mode.PRE, cn.frames.get_local("origin"), cn.c.sizeof.struct_s, nil))
    cn.error_stack.pop()
    cn.error_stack.push("  Or.y == 0i32;\n  ^~~~~~~~~~~~~~~~~~ ./lua_gen_output/basic_owned_example.c:18:3-21")
    cn.assert(cn.equals(cn.frames.get_local("Or").y(), 0), cn.spec_mode.PRE)
    cn.error_stack.pop()

    print("SIMPLE OWNED PRECOND PASSED")
end

function cn.simple_owned.push_frame(origin)
    cn.frames.push_function()
    cn.frames.set_local("origin", origin())
end

function cn.simple_owned.postcondition()
    cn.frames.set_local("Or__cn", cn.owned(cn.spec_mode.POST, cn.frames.get_local("origin"), cn.c.sizeof.struct_s, nil))

    print("SIMPLE OWNED POSTCOND PASSED")
end

function cn.addtl_indirection_owned.precondition()
    cn.error_stack.push("  take Or = RW<struct s*>(origin);\n       ^./lua_gen_output/basic_owned_example.c:30:8:")
    cn.frames.set_local("Or", cn.owned(cn.spec_mode.PRE, cn.frames.get_local("origin"), cn.c.sizeof.struct_s, nil))
    cn.error_stack.pop()
    cn.error_stack.push("  take Or_ = RW<struct s>(Or);\n       ^./lua_gen_output/basic_owned_example.c:31:8:")
    cn.frames.set_local("Or_", cn.owned(cn.spec_mode.PRE, cn.frames.get_local("Or"), cn.c.sizeof.struct_s, nil))
    cn.error_stack.pop()
    cn.error_stack.push("  Or_.y == 7i32;\n  ^~~~~~~~~~~~~~ ./lua_gen_output/basic_owned_example.c:32:3-17")
    cn.assert(cn.equals(cn.frames.get_local("Or_").y(), 7), cn.spec_mode.PRE)
    cn.error_stack.pop()

    print("ADDTL_INDIRECTION PRECOND PASSED")
end

function cn.addtl_indirection_owned.push_frame(origin)
    cn.frames.push_function()
    cn.frames.set_local("origin", origin())
end

function cn.addtl_indirection_owned.postcondition()
    cn.error_stack.push("  take Or = RW<struct s*>(origin);\n       ^./lua_gen_output/basic_owned_example.c:34:8:")
    cn.frames.set_local("Or", cn.owned(cn.spec_mode.POST, cn.frames.get_local("origin"), cn.c.sizeof.struct_s, nil))
    cn.error_stack.pop()
    cn.error_stack.push("  take Or_ = RW<struct s>(Or);\n       ^./lua_gen_output/basic_owned_example.c:35:8:")
    cn.frames.set_local("Or_", cn.owned(cn.spec_mode.POST, cn.frames.get_local("Or"), cn.c.sizeof.struct_s, nil))
    cn.error_stack.pop()
    cn.error_stack.push("  Or_.y == 0i32;\n  ^~~~~~~~~~~~~~ ./lua_gen_output/basic_owned_example.c:36:3-17")
    cn.assert(cn.equals(cn.frames.get_local("Or_").y(), 0), cn.spec_mode.POST)
    cn.error_stack.pop()

    print("ADDTL_INDIRECTION POSTCOND PASSED")
end

return cn