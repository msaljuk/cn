local cn = require("lua_cn_runtime_core")

_ENV = cn.env

local seq = {
    Seq_Nil = function () return { tag = "SEQ_NIL" } end,
    Seq_Cons = function (head, tail) return { tag = "SEQ_CONS", head = head, tail = tail } end
}

local function append(xs, ys)
    if cn.equals(xs.tag, "SEQ_NIL") then
        return ys
    elseif cn.equals(xs.tag, "SEQ_CONS") then
        local zs = xs.tail
        local h = xs.head
        return seq.Seq_Cons(h, append(zs, ys))
    end
end

local function split_cn(xs)
    if cn.equals(xs.tag, "SEQ_NIL") then
        return { fst = seq.Seq_Nil(), snd = seq.Seq_Nil() }
    elseif cn.equals(xs.tag, "SEQ_CONS") then
        if cn.equals(xs.tail.tag, "SEQ_NIL") then
            local h1 = xs.head
            return { fst = seq.Seq_Nil(), snd = xs }
        elseif cn.equals(xs.tail.tag, "SEQ_CONS") then
            local tl2 = xs.tail.tail
            local h2 = xs.tail.head
            local h1 = xs.head
            local P = split_cn(tl2)
            return { fst = seq.Seq_Cons(h1, P.fst), snd = seq.Seq_Cons(h2, P.snd) }
        end
    end
end

local function IntList(p, spec_mode, loop_ownership)
    if is_null(p) then
        return seq.Seq_Nil()
    else
        local H = cn.owned(spec_mode, p, cn.c.sizeof.int_list, loop_ownership, cn.c.get_int_list)
        local tl = IntList(H.tail, spec_mode, loop_ownership)
        return seq.Seq_Cons(H.head, tl)
    end
end

function cn.IntList_append.precondition()
    cn.error_stack.push("/*@ requires take L1 = IntList(xs);\n                  ^./tests/cn/append.c:35:19:")
    cn.locals.L1 = IntList(cn.locals.xs, cn.spec_mode.PRE, nil)
    cn.error_stack.pop()
    cn.error_stack.push("             take L2 = IntList(ys);\n                  ^./tests/cn/append.c:36:19:")
    cn.locals.L2 = IntList(cn.locals.ys, cn.spec_mode.PRE, nil)
    cn.error_stack.pop()
end

function cn.IntList_append.push_frame(xs, ys)
    cn.frames.push_function()
    cn.locals.xs = xs
    cn.locals.ys = ys
end

function cn.IntList_append.postcondition(__cn_ret)
    cn.error_stack.push("    ensures take L3 = IntList(return);\n                 ^./tests/cn/append.c:37:18:")
    cn.locals.L3 = IntList(__cn_ret, cn.spec_mode.POST, nil)
    cn.error_stack.pop()
    cn.error_stack.push("            L3 == append(L1, L2); @*/\n            ^~~~~~~~~~~~~~~~~~~~~ ./tests/cn/append.c:38:13-34")
    cn.assert(cn.equals(cn.locals.L3, append(cn.locals.L1, cn.locals.L2)), cn.spec_mode.POST)
    cn.error_stack.pop()
end

function cn.split.precondition()
    cn.error_stack.push("/*@ requires take Xs = IntList(xs);\n                  ^./tests/cn/append.c:84:19:")
    cn.locals.Xs = IntList(cn.locals.xs, cn.spec_mode.PRE, nil)
    cn.error_stack.pop()
end

function cn.split.push_frame(xs)
    cn.frames.push_function()
    cn.locals.xs = xs
end

function cn.split.postcondition(__cn_ret)
    cn.error_stack.push("    ensures take Ys = IntList(return.fst);\n                 ^./tests/cn/append.c:85:18:")
    cn.locals.Ys = IntList(__cn_ret.fst, cn.spec_mode.POST, nil)
    cn.error_stack.pop()
    cn.error_stack.push("            take Zs = IntList(return.snd); @*/\n                 ^./tests/cn/append.c:86:18:")
    cn.locals.Zs = IntList(__cn_ret.snd, cn.spec_mode.POST, nil)
    cn.error_stack.pop()
end

function cn.main.precondition()

end

function cn.main.push_frame()
    cn.frames.push_function()
end

function cn.main.postcondition(__cn_ret)

end

return cn
