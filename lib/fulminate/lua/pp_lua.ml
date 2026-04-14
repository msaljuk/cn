module LuaS = Lua_syntax
include PPrint

let indent block ?(comma = false) () =
    let sep = if comma then ",\n" else "\n" in
    let indent_line (line : string) : string =
        if Stdlib.((=) line "") then "" else "    " ^ line
    in
    let process_string (s : string) : string =
        let lines = Stdlib.String.split_on_char '\n' s in
        let indented = Stdlib.List.map indent_line lines in
        Stdlib.String.concat "\n" indented
    in
    let indented_block = Stdlib.List.map process_string block in
    Stdlib.String.concat sep indented_block

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
    | LuaS.Binary (args) ->
        let lua_c_type_prefix = "c_num" in
        let get_c_type t = LuaS.Field(LuaS.Symbol(lua_c_type_prefix), LuaS.Symbol(t)) in
        let c_type_op t o args 
            = LuaS.Call(pp_expr (LuaS.Field(get_c_type t, LuaS.Symbol(o))), args)
        in

        let pp_binary_expr_type expr = 
            match expr with
                | LuaS.Or(a, b) -> pp_expr (LuaS.Call("bool_or", [ a; b ]))
                | LuaS.And(a, b) -> pp_expr (LuaS.Call("bool_and", [ a; b ]))
                | LuaS.Add(a, b, t) -> pp_expr (c_type_op t "add" [ a; b ])
                | LuaS.Subtract(a, b, t) -> pp_expr (c_type_op t "sub" [ a; b ])
                | LuaS.Multiply(a, b, t) -> pp_expr (c_type_op t "mul" [ a; b ])
                | LuaS.IntegerDivide(a, b, t) -> pp_expr (c_type_op t "div" [ a; b ])
                | LuaS.FloatDivide(_a, _b) -> failwith "Float Divide not supported yet"
                | LuaS.Exp(a, b, t) -> pp_expr (c_type_op t "exp" [ a; b ])
                | LuaS.Remainder(a, b, t) -> pp_expr (c_type_op t "rem" [ a; b ])
                | LuaS.Modulo(a, b, t) -> pp_expr (c_type_op t "mod" [ a; b ])
                | LuaS.LessThan(a, b, t) -> pp_expr (c_type_op t "lt" [ a; b ])
                | LuaS.LessThanOrEqTo(a, b, t) -> pp_expr (c_type_op t "le" [ a; b ])
                | LuaS.Min(a, b, t) -> pp_expr (c_type_op t "min" [ a; b ])
                | LuaS.Max(a, b, t) -> pp_expr (c_type_op t "max" [ a; b ])
                | LuaS.BW_Xor(a, b, t) -> pp_expr (c_type_op t "bw_xor" [ a; b ])
                | LuaS.BW_And(a, b, t) -> pp_expr (c_type_op t "bw_and" [ a; b ])
                | LuaS.BW_Or(a, b, t) -> pp_expr (c_type_op t "bw_or" [ a; b ])
                | LuaS.LeftShift(a, b, t) -> pp_expr (c_type_op t "shl" [ a; b ])
                | LuaS.RightShift(a, b, t) -> pp_expr (c_type_op t "shr" [ a; b ])
                | LuaS.Eq(a, b) -> pp_expr (LuaS.Call("equals", [ a; b ]))
        in
        pp_binary_expr_type args

and pp_stmt = function
    | LuaS.Assign (id, e) ->
      id ^ " = " ^ (pp_expr e)
    | LuaS.LocalAssign (id, e) -> 
        "local " ^ id ^ " = " ^ (pp_expr e)

    | LuaS.FunctionDef (fn, args, body) ->
        pp_fn fn args body ()
    | LuaS.LocalFunctionDef (fn, args, body) ->
        "local " ^ pp_fn fn args body ()
    | LuaS.FunctionCall (fn, args) ->
        pp_expr (LuaS.Call(fn, args))
    | LuaS.Return (expr) ->
        "return " ^ pp_expr (expr)
    | LuaS.IfElse (cases) ->
        let pp_if_statement cases =
            let render_body b = indent (List.map pp_stmt b) () in

            match cases with
                | [] -> failwith "Syntax Error: Must provide at least one valid case"
                (* If *)
                | (Some cond, if_body) :: rest ->
                    let head_str = "if " ^ pp_expr cond ^ " then\n" ^ render_body if_body in

                    let rec build_cases = function
                        | [] -> "\nend"
                        (* Else *)
                        | [(None, else_body)] -> 
                            "\nelse\n" ^ render_body else_body ^ "\nend"
                        (* Else if *)
                        | [(Some c, b)] -> 
                            "\nelseif " ^ pp_expr c ^ " then\n" ^ render_body b ^ "\nend"
                        | (Some c, b) :: next -> 
                            "\nelseif " ^ pp_expr c ^ " then\n" ^ render_body b ^ build_cases next
                        | (None, _) :: _ -> failwith "Syntax Error: 'else' must be the last case."
                    in
                    head_str ^ build_cases rest
                | (None, _) :: _ -> failwith "Syntax Error: 'if' statement must start with a condition."
        in
        pp_if_statement cases
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
