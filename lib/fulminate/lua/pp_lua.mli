module LuaS = Lua_syntax

(* Prints a Lua expression as a string *)
val pp_expr : LuaS.expr -> string

(* Prints a Lua statement as a string *)
val pp_stmt : LuaS.stmt -> string
