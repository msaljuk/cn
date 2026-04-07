local cn = require("lua_cn_runtime_core")

function cn.callme.precondition()
    cn.error_stack.push("    take bb   = Owned<int>(b);\n         ^./lua_gen_output/canonical_example.c:6:10:")
    cn.locals.bb = cn.owned(cn.spec_mode.PRE, cn.locals.b, cn.c.sizeof.int, nil, cn.c.get_integer)
    cn.error_stack.pop()

    cn.error_stack.push("    take s1_b = Owned<int>(member_shift<struct s>(s1, b));\n         ^./lua_gen_output/canonical_example.c:7:10:")
    cn.locals.s1_b = cn.owned(cn.spec_mode.PRE, cn.member_shift(cn.locals.s1, cn.c.offsets.s.b), cn.c.sizeof.int, nil, cn.c.get_integer)
    cn.error_stack.pop()

    cn.error_stack.push("    take ss2  = Owned(s2);\n         ^./lua_gen_output/canonical_example.c:8:10:")
    cn.locals.ss2 = cn.owned(cn.spec_mode.PRE, cn.locals.s2, cn.c.sizeof.s, nil, cn.c.get_s)
    cn.error_stack.pop()

    cn.error_stack.push("    take cc   = Owned(c);\n         ^./lua_gen_output/canonical_example.c:9:10:")
    cn.locals.cc = cn.owned(cn.spec_mode.PRE, cn.locals.c, cn.c.sizeof.pointer, nil, cn.c.get_pointer)
    cn.error_stack.pop()

    cn.error_stack.push("    take ccc  = Owned(cc);\n         ^./lua_gen_output/canonical_example.c:10:10:")
    cn.locals.ccc = cn.owned(cn.spec_mode.PRE, cn.locals.cc, cn.c.sizeof.pointer, nil, cn.c.get_pointer)
    cn.error_stack.pop()
    
    cn.error_stack.push("    take cccc = Owned(ccc);\n         ^./lua_gen_output/canonical_example.c:11:10:")
    cn.locals.cccc = cn.owned(cn.spec_mode.PRE, cn.locals.ccc, cn.c.sizeof.int, nil, cn.c.get_integer)
    cn.error_stack.pop()

    cn.error_stack.push("    a == 42i32;\n    ^~~~~~~~~~~ ./lua_gen_output/canonical_example.c:12:5-16")
    cn.assert(cn.equals(cn.locals.a, 42), cn.spec_mode.PRE)
    cn.error_stack.pop()

    cn.error_stack.push("    bb == 43i32;\n    ^~~~~~~~~~~~ ./lua_gen_output/canonical_example.c:13:5-17")
    cn.assert(cn.equals(cn.locals.bb, 43), cn.spec_mode.PRE)
    cn.error_stack.pop()

    cn.error_stack.push("    cccc == 44i32;\n    ^~~~~~~~~~~~~~ ./lua_gen_output/canonical_example.c:14:5-19")
    cn.assert(cn.equals(cn.locals.cccc, 44), cn.spec_mode.PRE)
    cn.error_stack.pop()

    cn.error_stack.push("    s0.a == s0.b;\n    ^~~~~~~~~~~~~ ./lua_gen_output/canonical_example.c:15:5-18")
    cn.assert(cn.equals(cn.locals.s0.a, cn.locals.s0.b), cn.spec_mode.PRE)
    cn.error_stack.pop()

    cn.error_stack.push("    s1_b == 45i32;\n    ^~~~~~~~~~~~~~ ./lua_gen_output/canonical_example.c:16:5-19")
    cn.assert(cn.equals(cn.locals.s1_b, 45), cn.spec_mode.PRE)
    cn.error_stack.pop()

    cn.error_stack.push("    ss2.a == ss2.b;\n    ^~~~~~~~~~~~~~~ ./lua_gen_output/canonical_example.c:17:5-20")
    cn.assert(cn.equals(cn.locals.ss2.a, cn.locals.ss2.b), cn.spec_mode.PRE)
    cn.error_stack.pop()
end

function cn.callme.push_frame(a, b, c, s0, s1, s2)
    cn.frames.push_function()
    cn.locals.a = a
    cn.locals.b = b
    cn.locals.c = c
    cn.locals.s0 = s0
    cn.locals.s1 = s1
    cn.locals.s2 = s2

    -- print("DEBUG PRINTING")
    -- print(cn.locals.a)
    -- print(cn.locals.b)
    -- print(cn.locals.c)
    -- for k,v in pairs(cn.locals.s0) do print(k,v) end
    -- print(cn.locals.s1)
    -- local reader_test = cn.c.get_s(cn.locals.s1)
    -- for k,v in pairs(reader_test) do print(k,v) end
    -- print(cn.locals.s2)
end

function cn.callme.postcondition()
end

return cn