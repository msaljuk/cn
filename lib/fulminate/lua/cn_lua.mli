module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax

(* ---------------------------------- *)
(* CN-Lua Types and related utilities *)
(* ---------------------------------- *)

type lua_statements = (LuaS.stmt list)
type ail_bindings_and_statements = (A.bindings * CF.GenTypes.genTypeCategory A.statement_ list)
(* Corresponds to a list of Lua statements and the wrapper C functions that call into it *)
type lua_cn_exec = (lua_statements * ail_bindings_and_statements)

val get_empty_lua_stmts : LuaS.stmt list
val get_empty_ail_bindings_and_stmts : ail_bindings_and_statements
val get_empty_lua_cn_exec : lua_cn_exec

(* 
Similar to List.concat. 

Takes a list of lua_cn_execs and returns one exec 
with the concatenated results of the input execs.
*)
val concat :
    lua_cn_exec list ->
    lua_cn_exec

(* ---------------------------------- *)
(*             Generators             *)
(* ---------------------------------- *)

(* 
Utility used to generate the name of the wrapper C function
that calls into Lua for the actual precondition check.
*)
val generate_c_precondition_fn_wrapper_name : Sym.t -> string

(* 
Utility used to generate the name of the wrapper C function
that calls into Lua for the actual postcondition check.
*)
val generate_c_postcondition_fn_wrapper_name : Sym.t -> string

(* 
Utility used to generate the definition of any wrapper C function
that calls into Lua. 

Takes in 
- the name of the wrapper function, 
- the name of the corresponding Lua function,
- the list of C args that need to be pushed into Lua.
*)
val generate_c_fn_wrapper_def 
    : string -> 
    string ->
    CF.GenTypes.genTypeCategory A.expression list ->
    CF.GenTypes.genTypeCategory A.statement_ list

(* 
Utility used to generate the filename of the Lua file (with .Lua extension)
based on the given C filename.
*)
val generate_lua_filename :
    string ->
    string

(* 
Utility used to generate the name of a Lua precondition function
based on the name of the C function where it is called.
*)
val generate_lua_precondition_fn_name : Sym.t -> string

(* 
Utility used to generate the name of a Lua postcondition function
based on the name of the C function where it is called.
*)
val generate_lua_postcondition_fn_name : Sym.t -> string

(* 
Utility used to generate the require for the Lua core runtime.
*)
val generate_lua_runtime_core_req : LuaS.stmt

(* 
Utility used to generate an error stack push statement in Lua,
with the provided error message.
*)
val generate_lua_cn_error_stack_push : string -> LuaS.stmt

(* 
Utility used to generate an error stack pop statement in Lua.
*)
val generate_lua_cn_error_stack_pop : LuaS.stmt

val generate_lua_cn_assert 
    : string -> 
    CF.GenTypes.genTypeCategory A.expression -> 
    string ->
    LuaS.stmt

