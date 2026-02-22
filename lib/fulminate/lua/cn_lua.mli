module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax

(* ---------------------------------- *)
(* CN-Lua Types and related utilities *)
(* ---------------------------------- *)

type lua_statements = (LuaS.stmt list)
type wrapper_function = (A.sigma_declaration * CF.GenTypes.genTypeCategory A.sigma_function_definition)
type wrapper_functions = (wrapper_function list)
(* Corresponds to a list of Lua statements and the wrapper C functions that call into them *)
type lua_cn_exec = (lua_statements * wrapper_functions)

val get_empty_lua_stmts : LuaS.stmt list
val get_empty_wrapper_functions : wrapper_functions
val get_empty_lua_cn_exec : lua_cn_exec

(* 
Similar to List.concat. 

Takes a list of lua_cn_execs and returns one exec 
with the concatenated results of the input execs.
*)
val concat 
    : lua_cn_exec list ->
    lua_cn_exec

(*
Utility used to convert an instrumented c function's args
to the arguments of the wrapper that will push them into Lua
*)
val convert_c_args_to_wrapper_args 
    : (CF.Ctype.union_tag * CF.Ctype.ctype) list ->
    (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list

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
Utility used to generate the name of the wrapper C function
that pushes a C function's args into Lua at the start of a frame.
*)
val generate_c_push_frame_fn_wrapper_name : Sym.t -> string

(* 
Utility used to generate a C function call to pop the most recent function frame
*)
val generate_c_pop_frame_fn_wrapper_call : CF.GenTypes.genTypeCategory A.statement_

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
    (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list ->
    wrapper_function

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
Utility used to generate the name of a Lua function that pushes a bunch
of C arguments onto the Lua CN frame at the start of a frame.
*)
val generate_lua_push_frame_fn_name : Sym.t -> string

(* 
Utility used to generate the require for the Lua core runtime.
*)
val generate_lua_runtime_core_req : LuaS.stmt

(*
Utility used to generate a Lua function that pushes a bunch of 
C arguments onto the Lua CN frame at the start of the frame. Takes
in the name of the function and the args to push. 
*)
val generate_lua_push_frame_fn 
    : string ->
    (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list ->
    LuaS.stmt 

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

