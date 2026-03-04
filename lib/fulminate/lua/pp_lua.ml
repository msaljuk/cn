module LuaS = Lua_syntax
include PPrint

let indent block =
  List.map (fun s -> "    " ^ s) block
  |> String.concat "\n" 

let rec pp_expr = function
  | LuaS.Nil -> "nil"
  | LuaS.Bool b -> string_of_bool b
  | LuaS.Number_Int (z : Z.t) -> Z.to_string z
  | LuaS.Number_Float (q : Q.t) -> Q.to_string q
  | LuaS.String s -> "\"" ^ s ^ "\""
  | LuaS.Symbol id -> id
  | LuaS.Field (k, v) ->
      Printf.sprintf "%s.%s" (pp_expr k) (pp_expr v)
  | LuaS.Call (fn, args) ->
      let args_str = String.concat ", " (List.map pp_expr args) in
      Printf.sprintf "%s(%s)" fn args_str

let rec pp_stmt = function
    | LuaS.Assign (id, e) ->
      id ^ " = " ^ (pp_expr e)
    | LuaS.LocalAssign (id, e) -> 
        "local " ^ id ^ " = " ^ (pp_expr e)

    | LuaS.FunctionDef (fn, args, body) ->
        let args_list = List.map pp_expr args in
        let header = Printf.sprintf "function %s(%s)" fn (String.concat ", " args_list) in
        let indented_body = indent (List.map pp_stmt body) in
        header ^ "\n" ^ indented_body ^ "\nend\n\n"
    | LuaS.FunctionCall (fn, args) ->
        pp_expr (LuaS.Call(fn, args))
    | LuaS.Return (expr) ->
        "return " ^ pp_expr (expr) 
    | _ -> ""
