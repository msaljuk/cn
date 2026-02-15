local cn = require("lua_cn_runtime_core")

function cn.asserts.Random12()
    cn.error_stack.push("      /*@ assert(false); @*/     // <-- should be unreachable\n          ^~~~~~~~~~~~~~ ./lua_gen_output/enum_test.c:17:11-25")
    cn.assert(false, cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end