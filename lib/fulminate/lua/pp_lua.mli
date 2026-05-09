(* Prints a Lua expression as a string *)
val pp_expr : Lua_syntax.expr -> string

(* Prints a Lua statement as a string *)
val pp_stmt : Lua_syntax.stmt -> string
