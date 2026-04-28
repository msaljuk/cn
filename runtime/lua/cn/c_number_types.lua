local function create_number_type(bits, signed)
    -- Handle 64-bit overflow for mask calculation
    local mask = (bits == 64) and -1 or (1 << bits) - 1
    local sign_bit = 1 << (bits - 1)
    
    local min_val, max_val
    if signed then
        -- i64 is special due to Lua's native representation
        min_val = (bits == 64) and (1 << 63) or -(1 << (bits - 1))
        max_val = (bits == 64) and ~(1 << 63) or (1 << (bits - 1)) - 1
    else
        min_val = 0
        max_val = mask
    end

    -- Internal wrapping function to mimic C type overflow and sign extension
    local function wrap(v)
        -- Replicate implicit boolean casting to integer
        if type(v) == "boolean" then
            v = v and 1 or 0
        end

        v = v & mask
        if signed and bits < 64 and (v & sign_bit) ~= 0 then
            return v - (mask + 1)
        end
        return v
    end

    local _lt = function(a, b)
        if not signed and bits == 64 then return math.ult(a, b) end
        return a < b
    end

    local T = {
        bits   = bits,
        signed = signed,
        mask   = mask,

        make = wrap,
        min_val = function() return min_val end,
        max_val = function() return max_val end,

        -- Arithmetic Ops
        add = function(a, b) return wrap(a + b) end,
        sub = function(a, b) return wrap(a - b) end,
        mul = function(a, b) return wrap(a * b) end,
        div = function(a, b)
            if b == 0 then error("div - lua c division by zero") end
            local r = math.fmod(a, b)
            return wrap((a - r) // b)
        end,
        -- MATCHES CN_GEN_REM
        rem = function(a, b)
            if b == 0 then error("rem - lua c division by zero") end
            return wrap(math.fmod(a, b))
        end,
        -- MATCHES CN_GEN_MOD
        mod = function(a, b)
            if b == 0 then error("mod - division by zero") end
            local r = math.fmod(a, b)
            if r < 0 then
                if b < 0 then
                    r = r - b
                else
                    r = r + b
                end
            end
            return wrap(r)
        end,
        neg = function (v) return wrap(-v) end,
        -- Can't use ^ for exp since Lua implicitly converts to floats for that
        -- and that reduces our range. Use manual multiplication
        exp = function(a, b)
            if b < 0 then
                if a == 1 then return 1
                elseif a == -1 then return (b % 2 == 0) and 1 or -1
                else return 0 end
            end
            local res = 1
            local base = a
            while b > 0 do
                if (b & 1) == 1 then res = wrap(res * base) end
                base = wrap(base * base)
                b = b >> 1
            end
            return wrap(res)
        end,

        -- Bitwise Ops
        bw_and   = function(a, b) return wrap(a & b) end,
        bw_or    = function(a, b) return wrap(a | b) end,
        bw_xor   = function(a, b) return wrap(a ~ b) end,
        bw_compl = function(a)    return wrap(~a) end,
        
        -- Shifts
        shl = function(a, n) 
            --[[
            C Fulminate has an interesting behavior where if the
            shift exceeds the number of available bits, we cap
            it at the max possible shift. Replicating that here.
            --]]
            local shift_mask = bits - 1
            local actual_shift = n & shift_mask
            return wrap(a << actual_shift) 
        end,
        shr = function(a, n)
            if signed then
                -- Emulate Arithmetic Right Shift (sign extension)
                return math.floor(a / (2^n))
            else
                -- Logical Right Shift (zero-fill)
                return wrap(a >> n)
            end
        end,

        -- Comparisons
        lt = _lt,
        le = function(a, b)
            if not signed and bits == 64 then return math.ult(a, b) or a == b end
            return a <= b
        end,
        gt = function(a, b)
            if not signed and bits == 64 then return not (math.ult(a, b) or a == b) end
            return a > b
        end,
        ge = function(a, b)
            if not signed and bits == 64 then return not math.ult(a, b) end
            return a >= b
        end,
        min = function(a, b)
            return _lt(a, b) and a or b
        end,
        max = function(a, b)
            return _lt(a, b) and b or a
        end,
    }

    return setmetatable(T, {
        __eq = function(t1, t2)
            return t1.bits == t2.bits and t1.signed == t2.signed
        end,
        __tostring = function(t)
            return string.format("%s%d", t.signed and "i" or "u", t.bits)
        end
    })
end

local types = {
    u8  = create_number_type(8,  false),
    u16 = create_number_type(16, false),
    u32 = create_number_type(32, false),
    u64 = create_number_type(64, false),
    
    i8  = create_number_type(8,  true),
    i16 = create_number_type(16, true),
    i32 = create_number_type(32, true),
    i64 = create_number_type(64, true),
}

return types