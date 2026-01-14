local cn = require("lua_cn_runtime_core")

cn.for_with_decl = {}

--[[
Loop Checks
--]]

cn.for_with_decl.loop_check = {}

function cn.for_with_decl.loop_check.a(i, acc)
    --@note This is popped at the end of the loop body
    cn.frames.push_loop()

    local ownership_state = cn.c.initialise_loop_ownership_state()

    cn.error_stack.push("  for(int i = 0; i < 10; i++)\n  ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:4:3-9:4")
    cn.ghost_state.get_or_put_ownership(cn.spec_mode.LOOP, i, cn.c.get_integer_size(), ownership_state)
    cn.error_stack.pop()

    cn.error_stack.push("  for(int i = 0; i < 10; i++)\n  ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:4:3-9:4")
    cn.ghost_state.get_or_put_ownership(cn.spec_mode.LOOP, acc, cn.c.get_integer_size(), ownership_state)
    cn.error_stack.pop()

    cn.error_stack.push("  /*@ inv 0i32 <= i; i <= 10i32;\n          ^~~~~~~~~~ ./tests/cn/forloop_with_decl.c:5:11-21")
    cn.assert(cn.c.get_integer(i) >= 0, cn.spec_mode.LOOP);
    cn.error_stack.pop()

    cn.error_stack.push("  /*@ inv 0i32 <= i; i <= 10i32;\n                     ^~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:5:22-33")
    cn.assert(cn.c.get_integer(i) <= 10, cn.spec_mode.LOOP);
    cn.error_stack.pop()

    cn.error_stack.push("  acc <= 10i32; @*/\n          ^~~~~~~~~~~~~ ./tests/cn/forloop_with_decl.c:6:11-24")
    cn.assert(cn.c.get_integer(acc) <= 10, cn.spec_mode.LOOP);
    cn.error_stack.pop()

    cn.c.loop_put_back_ownership(ownership_state)
end

return cn