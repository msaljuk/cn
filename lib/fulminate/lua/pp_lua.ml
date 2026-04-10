module LuaS = Lua_syntax
include PPrint

let indent block ?(comma = false) () =
    let sep = if comma then ",\n" else "\n" in
    List.map (fun s -> "    " ^ s) block
    |> String.concat sep

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
    | LuaS.Function(args, body, is_multiline) ->
        pp_fn "" args body ~is_multiline:is_multiline ()
    | LuaS.Table (members, is_multiline : LuaS.table_field_type list * bool) ->
        let pp_table_field (table_field : LuaS.table_field_type) = 
            match table_field with
                | LuaS.Named(k, v) -> k ^ " = " ^ pp_expr v
                | LuaS.List(x) -> pp_expr x
        in
        if is_multiline then (
            let table_body = indent (List.map pp_table_field members) ~comma:true () in
            "{\n" ^ table_body ^ "\n}\n\n"
        ) else (
            let table_body = String.concat ", " (List.map pp_table_field members) in
            "{ " ^ table_body ^ " }"
        )

and pp_stmt = function
    | LuaS.Assign (id, e) ->
      id ^ " = " ^ (pp_expr e)
    | LuaS.LocalAssign (id, e) -> 
        "local " ^ id ^ " = " ^ (pp_expr e)

    | LuaS.FunctionDef (fn, args, body) ->
        pp_fn fn args body ()
    | LuaS.FunctionCall (fn, args) ->
        pp_expr (LuaS.Call(fn, args))
    | LuaS.Return (expr) ->
        "return " ^ pp_expr (expr)
    | LuaS.SExpr (expr) -> pp_expr expr
    | _ -> ""

and pp_fn fn_name fn_args fn_body ?(is_multiline=true) () =
    let args_list = List.map pp_expr fn_args in
    let header = Printf.sprintf "function %s(%s)" fn_name (String.concat ", " args_list) in
    let end_str = if is_multiline then "\nend\n\n" else " end" in
    let body = (List.map pp_stmt fn_body) in

    if is_multiline then (
        let indented_body = indent body () in
        header ^ "\n" ^ indented_body ^ end_str
    ) else (
        header ^ " " ^ (String.concat "" body) ^ end_str
    )
