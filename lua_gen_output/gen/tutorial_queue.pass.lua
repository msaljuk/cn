local cn = require("lua_cn_runtime_core")

_ENV = cn.env

function cn.push_globals()

end

local List = {
    Nil = function () return { tag = "NIL" } end,
    Cons = function (Head, Tail) return { tag = "CONS", Head = Head, Tail = Tail } end
}

local function Hd(L)
    if equals(L.tag, "NIL") then
        return c_num.i32.make(0)
    elseif equals(L.tag, "CONS") then
        local H = L.Head
        return H
    end
end

local function Tl(L)
    if equals(L.tag, "NIL") then
        return List.Nil()
    elseif equals(L.tag, "CONS") then
        local T = L.Tail
        return T
    end
end

local function Snoc(Xs, Y)
    if equals(Xs.tag, "NIL") then
        return List.Cons(Y, List.Nil())
    elseif equals(Xs.tag, "CONS") then
        local Zs = Xs.Tail
        local X = Xs.Head
        return List.Cons(X, Snoc(Zs, Y))
    end
end

local function SLList_At(p, spec_mode, loop_ownership)
    if is_null(p) then
        return List.Nil()
    else
        local H = owned(spec_mode, p, cn.c.sizeof.sllist, loop_ownership, cn.c.get_sllist)
        local T = SLList_At(H.tail, spec_mode, loop_ownership)
        return List.Cons(H.head, T)
    end
end

local function QueueAux(f, b, spec_mode, loop_ownership)
    if ptr_eq(f, b) then
        return List.Nil()
    else
        local F = owned(spec_mode, f, cn.c.sizeof.queue_cell, loop_ownership, cn.c.get_queue_cell)
        cn.error_stack.push("    assert (!is_null(F.next));  \n    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:77:5-80:40")
        cn.assert(not is_null(F.next), spec_mode)
        cn.error_stack.pop()
        cn.error_stack.push("    assert (ptr_eq(F.next, b) || !addr_eq(F.next, b));\n    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:78:5-80:40")
        cn.assert(bool_or(ptr_eq(F.next, b), not addr_eq(F.next, b)), spec_mode)
        cn.error_stack.pop()
        local B = QueueAux(F.next, b, spec_mode, loop_ownership)
        return List.Cons(F.first, B)
    end
end

local function QueueFB(front, back, spec_mode, loop_ownership)
    if is_null(front) then
        return List.Nil()
    else
        local B = owned(spec_mode, back, cn.c.sizeof.queue_cell, loop_ownership, cn.c.get_queue_cell)
        cn.error_stack.push("    assert (is_null(B.next));\n    ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:90:5-93:28")
        cn.assert(is_null(B.next), spec_mode)
        cn.error_stack.pop()
        cn.error_stack.push("    assert (ptr_eq(front, back) || !addr_eq(front, back));\n    ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:91:5-93:28")
        cn.assert(bool_or(ptr_eq(front, back), not addr_eq(front, back)), spec_mode)
        cn.error_stack.pop()
        local L = QueueAux(front, back, spec_mode, loop_ownership)
        return Snoc(L, B.first)
    end
end

local function QueuePtr_At(q, spec_mode, loop_ownership)
    local Q = owned(spec_mode, q, cn.c.sizeof.queue, loop_ownership, cn.c.get_queue)
    cn.error_stack.push("  assert (   (is_null(Q.front)  && is_null(Q.back)) \n  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:100:3-103:11")
    cn.assert(bool_or(bool_and(is_null(Q.front), is_null(Q.back)), bool_and(not is_null(Q.front), not is_null(Q.back))), spec_mode)
    cn.error_stack.pop()
    local L = QueueFB(Q.front, Q.back, spec_mode, loop_ownership)
    return L
end

function cn.lemma.snoc_facts.precondition(front, back, x)
    cn.error_stack.push("      take Q = QueueAux(front, back);\n           ^./tests/cn-test-gen/src/tutorial_queue.pass.c:157:12:")
    cn.locals.Q = QueueAux(front, back, cn.spec_mode.PRE, nil)
    cn.error_stack.pop()

    cn.error_stack.push("      take B = Owned<struct queue_cell>(back);\n           ^./tests/cn-test-gen/src/tutorial_queue.pass.c:158:12:")
    cn.locals.B = owned(cn.spec_mode.PRE, back, cn.c.sizeof.queue_cell, nil, cn.c.get_queue_cell)
    cn.error_stack.pop()
end

function cn.lemma.snoc_facts.postcondition(front, back, x)
    cn.error_stack.push("      take Q_post = QueueAux(front, back);\n           ^./tests/cn-test-gen/src/tutorial_queue.pass.c:160:12:")
    cn.locals.Q_post = QueueAux(front, back, cn.spec_mode.POST, nil)
    cn.error_stack.pop()

    cn.error_stack.push("      take B_post = Owned<struct queue_cell>(back);\n           ^./tests/cn-test-gen/src/tutorial_queue.pass.c:161:12:")
    cn.locals.B_post = owned(cn.spec_mode.POST, back, cn.c.sizeof.queue_cell, nil, cn.c.get_queue_cell)
    cn.error_stack.pop()

    cn.error_stack.push("      Q == Q_post; B == B_post;\n      ^~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:162:7-19")
    cn.assert(equals(cn.locals.Q, cn.locals.Q_post), cn.spec_mode.POST)
    cn.error_stack.pop()

    cn.error_stack.push("      Q == Q_post; B == B_post;\n                   ^~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:162:20-32")
    cn.assert(equals(cn.locals.B, cn.locals.B_post), cn.spec_mode.POST)
    cn.error_stack.pop()
    cn.locals.L = Snoc(List.Cons(x, cn.locals.Q), cn.locals.B.first)

    cn.error_stack.push("      Hd(L) == x;\n      ^~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:164:7-18")
    cn.assert(equals(Hd(cn.locals.L), x), cn.spec_mode.POST)
    cn.error_stack.pop()

    cn.error_stack.push("      Tl(L) == Snoc (Q, B.first);\n      ^~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:165:7-34")
    cn.assert(equals(Tl(cn.locals.L), Snoc(cn.locals.Q, cn.locals.B.first)), cn.spec_mode.POST)
    cn.error_stack.pop()
end

function cn.lemma.snoc_facts(front, back, x)
    cn.frames.push_function()
    cn.lemma.snoc_facts.precondition(front, back, x)
    cn.lemma.snoc_facts.postcondition(front, back, x)
    cn.frames.pop_function()
end

function cn.empty_queue.precondition()

end

function cn.empty_queue.push_frame()
    cn.frames.push_function()
end

function cn.empty_queue.postcondition(__cn_ret)
    cn.error_stack.push("/*@ ensures take ret = QueuePtr_At(return);\n                 ^./tests/cn-test-gen/src/tutorial_queue.pass.c:109:18:")
    cn.locals.ret = QueuePtr_At(__cn_ret, cn.spec_mode.POST, nil)
    cn.error_stack.pop()

    cn.error_stack.push("            ret == Nil{};\n            ^~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:110:13-26")
    cn.assert(equals(cn.locals.ret, List.Nil()), cn.spec_mode.POST)
    cn.error_stack.pop()
end

function cn.push_lemma.precondition()
    cn.error_stack.push("      take Q = QueueAux(front, p);\n           ^./tests/cn-test-gen/src/tutorial_queue.pass.c:124:12:")
    cn.locals.Q = QueueAux(cn.locals.front, cn.locals.p, cn.spec_mode.PRE, nil)
    cn.error_stack.pop()

    cn.error_stack.push("      take P = Owned<struct queue_cell>(p);\n           ^./tests/cn-test-gen/src/tutorial_queue.pass.c:125:12:")
    cn.locals.P = owned(cn.spec_mode.PRE, cn.locals.p, cn.c.sizeof.queue_cell, nil, cn.c.get_queue_cell)
    cn.error_stack.pop()

    cn.error_stack.push("      !is_null(P.next);\n      ^~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:126:7-24")
    cn.assert(not is_null(cn.locals.P.next), cn.spec_mode.PRE)
    cn.error_stack.pop()
end

function cn.push_lemma.push_frame(front, p)
    cn.frames.push_function()
    cn.locals.front = front
    cn.locals.p = p
end

function cn.push_lemma.postcondition()
    cn.error_stack.push("      take NewQ = QueueAux(front, P.next);\n           ^./tests/cn-test-gen/src/tutorial_queue.pass.c:128:12:")
    cn.locals.NewQ = QueueAux(cn.locals.front, cn.locals.P.next, cn.spec_mode.POST, nil)
    cn.error_stack.pop()

    cn.error_stack.push("      NewQ == Snoc(Q, P.first);\n      ^~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:129:7-32")
    cn.assert(equals(cn.locals.NewQ, Snoc(cn.locals.Q, cn.locals.P.first)), cn.spec_mode.POST)
    cn.error_stack.pop()
end

function cn.push_queue.precondition()
    cn.error_stack.push("/*@ requires take Q = QueuePtr_At(q);\n                  ^./tests/cn-test-gen/src/tutorial_queue.pass.c:134:19:")
    cn.locals.Q = QueuePtr_At(cn.locals.q, cn.spec_mode.PRE, nil)
    cn.error_stack.pop()
end

function cn.push_queue.push_frame(x, q)
    cn.frames.push_function()
    cn.locals.x = x
    cn.locals.q = q
end

function cn.push_queue.postcondition()
    cn.error_stack.push("    ensures take Q_post = QueuePtr_At(q);\n                 ^./tests/cn-test-gen/src/tutorial_queue.pass.c:135:18:")
    cn.locals.Q_post = QueuePtr_At(cn.locals.q, cn.spec_mode.POST, nil)
    cn.error_stack.pop()

    cn.error_stack.push("            Q_post == Snoc (Q, x);\n            ^~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:136:13-35")
    cn.assert(equals(cn.locals.Q_post, Snoc(cn.locals.Q, cn.locals.x)), cn.spec_mode.POST)
    cn.error_stack.pop()
end

function cn.pop_queue.precondition()
    cn.error_stack.push("/*@ requires take Q = QueuePtr_At(q);\n                  ^./tests/cn-test-gen/src/tutorial_queue.pass.c:169:19:")
    cn.locals.Q = QueuePtr_At(cn.locals.q, cn.spec_mode.PRE, nil)
    cn.error_stack.pop()

    cn.error_stack.push("             Q != Nil{};\n             ^~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:170:14-25")
    cn.assert(not equals(cn.locals.Q, List.Nil()), cn.spec_mode.PRE)
    cn.error_stack.pop()
end

function cn.pop_queue.push_frame(q)
    cn.frames.push_function()
    cn.locals.q = q
end

function cn.inline.instance0(q)

end

function cn.inline.instance1(h, q)
    local read_h0 = h
    local read_q1 = q
    local deref_read_q10 = cn.c.get_queue(read_q1)
    cn.error_stack.push("    /*@ assert ((alloc_id) h == (alloc_id) (q->back)); @*/\n        ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:179:9-55")
    cn.assert(equals(nil, nil), cn.spec_mode.STATEMENT)
    cn.error_stack.pop()
end

function cn.inline.instance2(x)

end

function cn.inline.instance3(h, q, x)
    local read_h1 = h
    local deref_read_h10 = cn.c.get_queue_cell(read_h1)
    local read_q2 = q
    local deref_read_q20 = cn.c.get_queue(read_q2)
    local read_x1 = x
    cn.lemma.snoc_facts(deref_read_h10.next, deref_read_q20.back, read_x1)
end

function cn.pop_queue.postcondition(__cn_ret)
    cn.error_stack.push("    ensures take Q_post = QueuePtr_At(q);\n                 ^./tests/cn-test-gen/src/tutorial_queue.pass.c:171:18:")
    cn.locals.Q_post = QueuePtr_At(cn.locals.q, cn.spec_mode.POST, nil)
    cn.error_stack.pop()

    cn.error_stack.push("            Q_post == Tl(Q);\n            ^~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:172:13-29")
    cn.assert(equals(cn.locals.Q_post, Tl(cn.locals.Q)), cn.spec_mode.POST)
    cn.error_stack.pop()

    cn.error_stack.push("            return == Hd(Q);\n            ^~~~~~~~~~~~~~~~ ./tests/cn-test-gen/src/tutorial_queue.pass.c:173:13-29")
    cn.assert(equals(__cn_ret, Hd(cn.locals.Q)), cn.spec_mode.POST)
    cn.error_stack.pop()
end

return cn
