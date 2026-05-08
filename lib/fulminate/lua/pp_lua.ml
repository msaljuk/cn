module LuaS = Lua_syntax
include PPrint

let indent block ?(comma = false) () =
  let sep = if comma then ",\n" else "\n" in
  let indent_line (line : string) : string =
    if Stdlib.(line = "") then "" else "    " ^ line
  in
  let process_string (s : string) : string =
    let lines = Stdlib.String.split_on_char '\n' s in
    let indented = Stdlib.List.map indent_line lines in
    Stdlib.String.concat "\n" indented
  in
  let indented_block = Stdlib.List.map process_string block in
  Stdlib.String.concat sep indented_block


let break (block : string list) (delimiter : string) =
  let contains s1 s2 =
    let re = Str.regexp_string s2 in
    try
      ignore (Str.search_forward re s1 0);
      true
    with
    | Not_found -> false
  in
  let rec loop found_first = function
    | [] -> []
    | x :: xs when contains x delimiter ->
      if not found_first then
        x :: loop true xs
      else
        ("\n" ^ x) :: loop true xs
    | x :: xs -> x :: loop found_first xs
  in
  block |> loop false


let rec pp_expr =
  let c_int_type_op t o args =
    LuaS.Call (pp_expr (LuaS.Field (LuaS.Symbol t, LuaS.Symbol o)), args)
  in
  let wrap int_type expr = pp_expr (c_int_type_op int_type "make" [ expr ]) in
  function
  | LuaS.Nil -> "nil"
  | LuaS.Bool b -> string_of_bool b
  | LuaS.Number (value : LuaS.expr) -> pp_expr value
  | LuaS.Number_Int ((value, t) : LuaS.expr * string) ->
    pp_expr (c_int_type_op t "make" [ value ])
  | LuaS.Number_IntLimit ((limit, t) : string * string) ->
    (match String.lowercase_ascii limit with
     | "max" -> pp_expr (c_int_type_op t "max_val" [])
     | "min" -> pp_expr (c_int_type_op t "min_val" [])
     | _ -> failwith "Only support min or max for limit parameter")
  | LuaS.Number_Float (q : Q.t) -> Q.to_string q
  | LuaS.String s -> "\"" ^ s ^ "\""
  | LuaS.Symbol id -> id
  | LuaS.Field (k, v) -> Printf.sprintf "%s.%s" (pp_expr k) (pp_expr v)
  | LuaS.Call (fn, args) ->
    let args_str = String.concat ", " (List.map pp_expr args) in
    Printf.sprintf "%s(%s)" fn args_str
  | LuaS.Function (args, body, is_multiline) -> pp_fn "" args body ~is_multiline ()
  | LuaS.Table ((members, is_multiline) : LuaS.table_field_type list * bool) ->
    let pp_table_field (table_field : LuaS.table_field_type) =
      match table_field with
      | LuaS.Named (k, v) -> k ^ " = " ^ pp_expr v
      | LuaS.List x -> pp_expr x
    in
    if List.is_empty members then
      "{}"
    else if is_multiline then (
      let table_body = indent (List.map pp_table_field members) ~comma:true () in
      "{\n" ^ table_body ^ "\n}\n\n")
    else (
      let table_body = String.concat ", " (List.map pp_table_field members) in
      "{ " ^ table_body ^ " }")
  | LuaS.TableGet (tbl, key) -> pp_expr tbl ^ "[" ^ pp_expr key ^ "]"
  | LuaS.TableSet (tbl, key, value) ->
    pp_expr (LuaS.TableGet (tbl, key)) ^ " = " ^ pp_expr value
  | LuaS.Binary args ->
    let pp_binary_expr_type expr =
      match expr with
      | LuaS.Or (a, b) -> pp_expr a ^ " or " ^ pp_expr b
      | LuaS.And (a, b) -> pp_expr a ^ " and " ^ pp_expr b
      | LuaS.AddI (a, b) -> pp_expr a ^ " + " ^ pp_expr b
      | LuaS.Add (a, b, t) ->
        let add_expr = LuaS.Symbol (pp_expr (LuaS.Binary (LuaS.AddI (a, b)))) in
        wrap t add_expr
      | LuaS.SubtractI (a, b) -> pp_expr a ^ " - " ^ pp_expr b
      | LuaS.Subtract (a, b, t) ->
        let subtract_expr = LuaS.Symbol (pp_expr (LuaS.Binary (LuaS.SubtractI (a, b)))) in
        wrap t subtract_expr
      | LuaS.MultiplyI (a, b) -> pp_expr a ^ " * " ^ pp_expr b
      | LuaS.Multiply (a, b, t) ->
        let multiply_expr = LuaS.Symbol (pp_expr (LuaS.Binary (LuaS.MultiplyI (a, b)))) in
        wrap t multiply_expr
      | LuaS.IntegerDivide (a, b, t) -> pp_expr (c_int_type_op t "div" [ a; b ])
      | LuaS.FloatDivide (_a, _b) -> failwith "Float Divide not supported yet"
      | LuaS.Exp (a, b, t) -> pp_expr (c_int_type_op t "exp" [ a; b ])
      | LuaS.Remainder (a, b, t) ->
        let rem_expr = LuaS.Call ("math.fmod", [ a; b ]) in
        wrap t rem_expr
      | LuaS.Modulo (a, b, t) -> pp_expr (c_int_type_op t "mod" [ a; b ])
      | LuaS.LessThan (a, b, t) ->
        (match t with
         | "i8" | "i16" | "i32" | "i64" -> pp_expr a ^ " < " ^ pp_expr b
         | _ -> pp_expr (LuaS.Call ("math.ult", [ a; b ])))
      | LuaS.LessThanOrEqTo (a, b, t) ->
        pp_expr (LuaS.Unary (LuaS.Not (LuaS.Binary (LuaS.LessThan (b, a, t)))))
      | LuaS.Min (a, b, t) -> pp_expr (c_int_type_op t "min" [ a; b ])
      | LuaS.Max (a, b, t) -> pp_expr (c_int_type_op t "max" [ a; b ])
      | LuaS.BW_Xor (a, b, t) -> pp_expr (c_int_type_op t "bw_xor" [ a; b ])
      | LuaS.BW_And (a, b, t) -> pp_expr (c_int_type_op t "bw_and" [ a; b ])
      | LuaS.BW_Or (a, b, t) -> pp_expr (c_int_type_op t "bw_or" [ a; b ])
      | LuaS.LeftShift (a, b, t) -> pp_expr (c_int_type_op t "shl" [ a; b ])
      | LuaS.RightShift (a, b, t) -> pp_expr (c_int_type_op t "shr" [ a; b ])
      | LuaS.Eq (a, b, t) ->
        (match t with
         | "u8" | "u16" | "u32" | "u64" | "i8" | "i16" | "i32" | "i64" ->
           pp_expr a ^ " == " ^ pp_expr b
         | _ -> 
          pp_expr (LuaS.Call ("equals", [ a; b ])))
    in
    pp_binary_expr_type args
  | LuaS.Unary args ->
    let pp_unary_expr_type args =
      let call_c_func name args =
        LuaS.Call
          ( pp_expr
              (LuaS.Field
                 (LuaS.Symbol "cn", LuaS.Field (LuaS.Symbol "c", LuaS.Symbol name))),
            args )
      in
      match args with
      | LuaS.Not v -> "not (" ^ pp_expr v ^ ")"
      | LuaS.Negate (v, t) ->
        let neg_expr = LuaS.Symbol ("-" ^ pp_expr v) in
        wrap t neg_expr
      | LuaS.BW_FLS v -> pp_expr (call_c_func "fls" [ v ])
      | LuaS.BW_FLSL v -> pp_expr (call_c_func "flsl" [ v ])
      | LuaS.BW_Complement (v, t) -> pp_expr (c_int_type_op t "bw_compl" [ v ])
    in
    pp_unary_expr_type args


and pp_stmt = function
  | LuaS.Assign (id, e_opt) ->
    (match e_opt with Some x -> id ^ " = " ^ pp_expr x | None -> id)
  | LuaS.Block stmts ->
    let stmts_str = List.map pp_stmt stmts in
    "do\n" ^ indent stmts_str () ^ "\nend"
  | LuaS.LocalAssign (id, e_opt) ->
    (match e_opt with
     | Some x -> "local " ^ id ^ " = " ^ pp_expr x
     | None -> "local " ^ id)
  | LuaS.FunctionDef (fn, args, body, break_errors) -> pp_fn fn args body ~break_errors ()
  | LuaS.LocalFunctionDef (fn, args, body) -> "local " ^ pp_fn fn args body ()
  | LuaS.FunctionCall (fn, args) -> pp_expr (LuaS.Call (fn, args))
  | LuaS.Return expr_opt ->
    (match expr_opt with Some x -> "return " ^ pp_expr x | None -> "return")
  | LuaS.IfElse cases ->
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
          | [ (None, else_body) ] -> "\nelse\n" ^ render_body else_body ^ "\nend"
          (* Else if *)
          | [ (Some c, b) ] ->
            "\nelseif " ^ pp_expr c ^ " then\n" ^ render_body b ^ "\nend"
          | (Some c, b) :: next ->
            "\nelseif " ^ pp_expr c ^ " then\n" ^ render_body b ^ build_cases next
          | (None, _) :: _ -> failwith "Syntax Error: 'else' must be the last case."
        in
        head_str ^ build_cases rest
      | (None, _) :: _ ->
        failwith "Syntax Error: 'if' statement must start with a condition."
    in
    pp_if_statement cases
  | LuaS.SExpr expr -> pp_expr expr
  | LuaS.While (cond, while_body) ->
    let while_cond = Printf.sprintf "while %s do\n" (pp_expr cond) in
    let body = List.map pp_stmt while_body in
    let indented_body = indent body () in
    while_cond ^ indented_body ^ "\nend"
  | LuaS.LineBreak -> "\n"
  | _ -> ""


and pp_fn fn_name fn_args fn_body ?(is_multiline = true) ?(break_errors = false) () =
  let args_list = List.map pp_expr fn_args in
  let header = Printf.sprintf "function %s(%s)" fn_name (String.concat ", " args_list) in
  let end_str = if is_multiline then "\nend\n\n" else " end" in
  let body =
    let initial = List.map pp_stmt fn_body in
    if break_errors then (
      (*@saljuk TODO: This is very gross. Find a cleaner solve *)
      let error_break = "error_stack.push" in
      break initial error_break)
    else
      initial
  in
  if is_multiline then (
    let indented_body = indent body () in
    header ^ "\n" ^ indented_body ^ end_str)
  else
    header ^ " " ^ String.concat "" body ^ end_str
