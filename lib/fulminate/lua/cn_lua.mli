module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax

(* Corresponds to a list of Lua statements and the wrapper C functions that call into it *)
type lua_cn_exec = (LuaS.stmt list) * (CF.GenTypes.genTypeCategory A.statement_ list)

val get_empty_lua_cn_exec : lua_cn_exec

val concat :
    lua_cn_exec list ->
    lua_cn_exec

val generate_lua_filename :
    string ->
    string

val generate_lua_runtime_core_req : LuaS.stmt

val generate_lua_cn_assert 
    : string -> 
    CF.GenTypes.genTypeCategory A.expression -> 
    string ->
    LuaS.stmt

val generate_lua_cn_error_stack_push : string -> LuaS.stmt

val generate_lua_cn_error_stack_pop : LuaS.stmt

(*val generate_lua_cn_frame_push_args 
    : (Sym.t * ((CF.Ctype.union_tag * CF.Ctype.ctype) list)) ->
    LuaS.stmt*)
