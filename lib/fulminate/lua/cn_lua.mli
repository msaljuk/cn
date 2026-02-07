module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax

type cn_stmt  = LuaS.stmt
type cn_stmts = cn_stmt list

val generate_lua_filename :
    string ->
    string

val generate_lua_runtime_core_req : LuaS.stmt

val generate_lua_cn_assert 
    : string -> 
    CF.GenTypes.genTypeCategory A.expression -> 
    string ->
    LuaS.stmt
