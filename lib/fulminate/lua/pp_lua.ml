let indent ?(comma = false) block =
  let sep = if comma then ",\n" else "\n" in
  let indent_line line = if Stdlib.(line = "") then "" else "    " ^ line in
  let process_string s =
    let lines = String.split_on_char '\n' s in
    let indented = List.map indent_line lines in
    String.concat "\n" indented
  in
  let indented_block = List.map process_string block in
  String.concat sep indented_block


let break block delimiter =
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


let mask = function
  | "i32"|"u32" -> "0xffffffff"
  | "i16"|"u16" -> "0xffff"
  | "i8" |"u8"  -> "0xff"
  | _ -> assert false
and sign = function
  | "i32" -> "0x80000000"
  | "i16" -> "0x8000"
  | "i8"  -> "0x80"
  | _ -> assert false
let normalised str = function
  | "i64"|"u64" -> "(" ^ str ^ ")"
  | ("u8"|"u16"|"u32" as t) -> "((" ^ str ^ ") & " ^ mask t ^ ")"
  | ("i8"|"i16"|"i32" as t) -> "(((" ^ str ^ ") & " ^ mask t ^ ") ~ " ^ sign t ^ " - " ^ sign t ^ ")"
  | _ -> assert false

open Lua_syntax

let rec pp_expr =
  let c_int_type_op t o args = Call (Field (Symbol t, Symbol o), args) in
  let wrap int_type expr = normalised (pp_expr expr) int_type in
  let pp_table_field = function
    | Named (k, v) -> k ^ " = " ^ pp_expr v
    | List x -> pp_expr x
  in
  function
  | Nil -> "nil"
  | Bool b -> string_of_bool b
  | Number value -> pp_expr value
  | Number_Int (value, t) -> pp_expr (c_int_type_op t "make" [ value ])
  | Number_IntLimit ("max", t) -> pp_expr (c_int_type_op t "max_val" [])
  | Number_IntLimit ("min", t) -> pp_expr (c_int_type_op t "min_val" [])
  | Number_IntLimit _ -> failwith "Only support min or max for limit parameter"
  | Number_Float q -> Q.to_string q
  | String s -> "\"" ^ s ^ "\""
  | Symbol id -> id
  | Field (k, v) -> Printf.sprintf "%s.%s" (pp_expr k) (pp_expr v)
  | Call (fn, args) ->
    let args_str = String.concat ", " (List.map pp_expr args) in
    Printf.sprintf "%s(%s)" (pp_expr fn) args_str
  | Function (args, body, is_multiline) -> pp_fn "" args body ~is_multiline ()
  | Table ([], _) -> "{}"
  | Table (members, true) ->
    "{\n" ^ indent (List.map pp_table_field members) ~comma:true ^ "\n}\n\n"
  | Table (members, false) ->
    "{ " ^ String.concat ", " (List.map pp_table_field members) ^ " }"
  | TableGet (tbl, key) -> pp_expr tbl ^ "[" ^ pp_expr key ^ "]"
  | TableSet (tbl, key, value) -> pp_expr (TableGet (tbl, key)) ^ " = " ^ pp_expr value
  | Binary args ->
    let pp_binary_expr_type expr =
      match expr with
      | Or (a, b) -> pp_expr a ^ " or " ^ pp_expr b
      | And (a, b) -> pp_expr a ^ " and " ^ pp_expr b
      | AddI (a, b) -> pp_expr a ^ " + " ^ pp_expr b
      | Add (a, b, t) ->
        let add_expr = Symbol (pp_expr (Binary (AddI (a, b)))) in
        wrap t add_expr
      | SubtractI (a, b) -> pp_expr a ^ " - " ^ pp_expr b
      | Subtract (a, b, t) ->
        let subtract_expr = Symbol (pp_expr (Binary (SubtractI (a, b)))) in
        wrap t subtract_expr
      | MultiplyI (a, b) -> pp_expr a ^ " * " ^ pp_expr b
      | Multiply (a, b, t) ->
        let multiply_expr = Symbol (pp_expr (Binary (MultiplyI (a, b)))) in
        wrap t multiply_expr
      | IntegerDivide (a, b, t) -> pp_expr (c_int_type_op t "div" [ a; b ])
      | FloatDivide (_a, _b) -> failwith "Float Divide not supported yet"
      | Exp (a, b, t) -> pp_expr (c_int_type_op t "exp" [ a; b ])
      | Remainder (a, b, t) ->
        let rem_expr = Call (Symbol "fmod", [ a; b ]) in
        wrap t rem_expr
      | Modulo (a, b, t) -> pp_expr (c_int_type_op t "mod" [ a; b ])
      | LessThan (a, b, ("i8" | "i16" | "i32" | "i64")) -> pp_expr a ^ " < " ^ pp_expr b
      | LessThan (a, b, _) -> pp_expr (Call (Symbol "ult", [ a; b ]))
      | LessThanOrEqTo (a, b, t) -> pp_expr (Unary (Not (Binary (LessThan (b, a, t)))))
      | Min (a, b, t) -> pp_expr (c_int_type_op t "min" [ a; b ])
      | Max (a, b, t) -> pp_expr (c_int_type_op t "max" [ a; b ])
      | BW_Xor (a, b, t) -> pp_expr (c_int_type_op t "bw_xor" [ a; b ])
      | BW_And (a, b, t) -> pp_expr (c_int_type_op t "bw_and" [ a; b ])
      | BW_Or (a, b, t) -> pp_expr (c_int_type_op t "bw_or" [ a; b ])
      | LeftShift (a, b, t) -> pp_expr (c_int_type_op t "shl" [ a; b ])
      | RightShift (a, b, (("u8" | "u16" | "u32" | "u64") as t)) ->
        let rhs_expr = Symbol (pp_expr a ^ " >> " ^ pp_expr b) in
        wrap t rhs_expr
      | RightShift (a, b, t) -> pp_expr (c_int_type_op t "shr" [ a; b ])
      | Eq (a, b, true) -> "(" ^ pp_expr a ^ " == " ^ pp_expr b ^ ")"
      | Eq (a, b, false) -> pp_expr (Call (Symbol "equals", [ a; b ]))
    in
    pp_binary_expr_type args
  | Unary args ->
    let pp_unary_expr_type args =
      let call_c_func name args =
        Call (Field (Symbol "cn", Field (Symbol "c", Symbol name)), args)
      in
      match args with
      | Not v -> "not (" ^ pp_expr v ^ ")"
      | Negate (v, t) ->
        let neg_expr = Symbol ("-" ^ pp_expr v) in
        wrap t neg_expr
      | BW_FLS v -> pp_expr (call_c_func "fls" [ v ])
      | BW_FLSL v -> pp_expr (call_c_func "flsl" [ v ])
      | BW_Complement (v, t) -> pp_expr (c_int_type_op t "bw_compl" [ v ])
    in
    pp_unary_expr_type args


and pp_stmt = function
  | Assign (id, None) -> id
  | Assign (id, Some x) -> id ^ " = " ^ pp_expr x
  | Block stmts ->
    let stmts_str = List.map pp_stmt stmts in
    "do\n" ^ indent stmts_str ^ "\nend"
  | LocalAssign (id, Some x) -> "local " ^ id ^ " = " ^ pp_expr x
  | LocalAssign (id, None) -> "local " ^ id
  | FunctionDef (fn, args, body, break_errors) -> pp_fn fn args body ~break_errors ()
  | LocalFunctionDef (fn, args, body) -> "local " ^ pp_fn fn args body ()
  | FunctionCall (fn, args) -> pp_expr (Call (fn, args))
  | Return (Some x) -> "return " ^ pp_expr x
  | Return None -> "return"
  | IfElse cases ->
    let pp_if_statement cases =
      let render_body b = indent (List.map pp_stmt b) in
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
  | SExpr expr -> pp_expr expr
  | While (cond, while_body) ->
    let while_cond = Printf.sprintf "while %s do\n" (pp_expr cond) in
    let body = List.map pp_stmt while_body in
    let indented_body = indent body in
    while_cond ^ indented_body ^ "\nend"
  | LineBreak -> "\n"
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
    let indented_body = indent body in
    header ^ "\n" ^ indented_body ^ end_str)
  else
    header ^ " " ^ String.concat "" body ^ end_str
