local cn = require("lua_cn_runtime_core")

cn.for_with_decl = {}

--[[
Loop Checks
--]]

cn.for_with_decl.loop_check = {}

function cn.for_with_decl.loop_check.a(i, acc)
    --@note This is popped at the end of the loop body
    cn.frames.push_loop()

    --[[
    This is unideal. For now, our contract has been to push everything CN related
    into Lua but keep the ownership state, error handling etc in C. Loops are
    annoying in that they have a whole ownership structure that we have to allocate
    but then we also use it for CN ownership checking. 
    
    Ideally, I'd push this all to Lua but the loop ownership struct is pretty strongly
    entangled rn with the rest of ownership checking and appears to be fairly
    optimized there. So that seems unwise.
    
    However, calling into C from here is also a half solve. This loop ownership state 
    isn't being bumped off either since we're not tracking the bump
    allocator at the callsite so we're in a weird state. Need to commit one way or the other.
    ]]--
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