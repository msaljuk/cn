module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax
module BT = BaseTypes
module IT = IndexTerms

(* ---------------------------------- *)
(* CN-Lua Types and related utilities *)
(* ---------------------------------- *)

type lua_expression = (LuaS.expr)
type lua_statement = (LuaS.stmt)
type lua_expressions = (lua_expression list)
type lua_statements = (lua_statement list)
type wrapper_function = (A.sigma_declaration * CF.GenTypes.genTypeCategory A.sigma_function_definition)
type wrapper_functions = (wrapper_function list)
(* 
Corresponds to a list of Lua statements and the wrapper C functions that call into them.

The final element in this tuple is the lua expression currently being constructed that, once
finalized, gets added to the list of lua statements. We're choosing to pack it in this type
to make it easy to bundle all lua data into one type instead of having to plumb multiple lua-related
fields in cn_to_ail.
*)
type lua_cn_exec = (lua_statements * wrapper_functions * lua_expression)

val get_empty_lua_expr : lua_expression
val get_empty_lua_stmt : lua_statement
val get_empty_lua_exprs : lua_expressions
val get_empty_lua_stmts : lua_statements
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

val push_expr_to_exec : (lua_cn_exec * lua_expression) -> lua_cn_exec
val pop_expr_from_exec : (lua_cn_exec) -> (lua_cn_exec * lua_expression)
val push_stmts_to_exec : (lua_cn_exec * lua_statements) -> lua_cn_exec

val wrap_sym_for_lua : Sym.t -> Sym.t

val expr_to_string : lua_expression -> string

val debug_print_stmts : lua_statements -> unit

(* ---------------------------------- *)
(*              Globals               *)
(* ---------------------------------- *)
val lua_init_function_generation : unit -> unit

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

val generate_c_assert_fn_wrapper_name : int -> string

val generate_c_assert_fn_wrapper_call : string -> CF.GenTypes.genTypeCategory A.statement_

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
Utility used to generate a function to push the size of a custom c struct onto the
sizeof table that exists in CN Lua
*)
val generate_c_fn_struct_size
    : A.ail_identifier ->
    wrapper_function

(*
Utility used to generate a function to peek at any custom C structs. Called from
Lua to get back a Lua table that is 'essentially' a mirrored version of the C struct,
with 2 main differences:
1. Every member is replaced by a pointer to that member (so a member 'x' becomes 'x_addr')
2. A size entry is appended to the very end of the table and represents the total size of the
struct in C (i.e. a sizeof)
*)
val generate_c_fn_peek_struct
    : (A.ail_identifier *
        (Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition)) ->
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

val generate_lua_assert_fn_name : int -> string

(* 
Utility used to generate the require for the Lua core runtime.
*)
val generate_lua_runtime_core_req : LuaS.stmt

val generate_lua_type_reader : CF.Ctype.ctype -> lua_expression

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

(* 
Utility used to generate a lua cn assert.

Takes in 
- the assert error message, 
- the current lua exec containing the assert expression
- the spec mode tag

Returns:
- The AIL wrapper function call to this assert 
(if SPEC_MODE is STATEMENT)
- The lua exec containing the generated assert 
(includes any wrapper defs and decls if SPEC_MODE is STATEMENT)
*)
val generate_lua_cn_assert 
    : string ->
    lua_cn_exec ->
    CF.Ctype.union_tag ->
    (CF.GenTypes.genTypeCategory A.statement_ list * lua_cn_exec)

val generate_lua_cn_return
    : lua_expression -> bool ->
    LuaS.stmt

val generate_lua_resource_get
    : lua_cn_exec ->
    lua_expression

val generate_lua_spec_mode
    : CF.Ctype.union_tag
    -> lua_expression

val generate_lua_resource
    : CF.Ctype.union_tag ->
    CF.Ctype.ctype ->
    lua_cn_exec ->
    lua_cn_exec

(* ---------------------------------- *)
(*          Cn-to-Lua Terms           *)
(* ---------------------------------- *)

(* 
Corollary to cn_to_ail_const.

Returns:
- a lua expression corresponding to the generated constant
- a bool flag indicating if it's unit or not.
*)
val cn_to_lua_const 
    : IT.const ->
    BT.t ->
    (lua_expression * bool)

val cn_to_lua_sym
    : CF.Ctype.union_tag ->
    (lua_expression)

val cn_to_lua_binop
    : (lua_expression * lua_expression * IT.binop) ->
    lua_expression

val cn_to_lua_apply
    : CF.Ctype.union_tag ->
    lua_cn_exec list ->
    (lua_cn_exec)