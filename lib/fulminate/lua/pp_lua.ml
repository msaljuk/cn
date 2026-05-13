let rec list_last = function
  | [] -> invalid_arg "list_last"
  | [ x ] -> ([], x)
  | x :: xs ->
    let h, t = list_last xs in
    (x :: h, t)


open Lua_syntax

(* Make this the real IfElse. *)
type the_real_if =
  | RealIfElse of (expr * stmt list) * (expr * stmt list) list * stmt list option

let the_real_if = function
  | (Some cond, stmts) :: rest ->
    let cons = (cond, stmts) in
    let alts, fin =
      match list_last rest with
      | alts, (None, []) -> (alts, None)
      | alts, (None, stmts) -> (alts, Some stmts)
      | _, (Some _, _) -> (rest, None)
    in
    let f = function Some cond, stmts -> (cond, stmts) | _ -> assert false in
    RealIfElse (cons, List.map f alts, fin)
  | _ -> assert false


open PPrint

let mask = function
  | "i32" | "u32" -> !^"0xffffffff"
  | "i16" | "u16" -> !^"0xffff"
  | "i8" | "u8" -> !^"0xff"
  | _ -> assert false


and sign = function
  | "i32" -> !^"0x80000000"
  | "i16" -> !^"0x8000"
  | "i8" -> !^"0x80"
  | _ -> assert false


let normalised pp t =
  let ( - ) = infix 1 1 !^"-"
  and ( land ) = infix 1 1 !^"&"
  and ( lxor ) = infix 1 1 !^"~" in
  match t with
  | "i64" | "u64" -> pp |> parens
  | ("u8" | "u16" | "u32") as t -> parens pp land mask t |> parens
  | ("i8" | "i16" | "i32") as t ->
    parens (parens pp land mask t lxor sign t) - sign t |> parens
  | _ -> assert false


let indent = 2

let width = 100

let c_int_type_op t o args = Call (Field (Symbol t, Symbol o), args)

let call_c_func name args =
  Call (Field (Symbol "cn", Field (Symbol "c", Symbol name)), args)


let rec pp_expr = function
  | Nil -> !^"nil"
  | Bool true -> !^"true"
  | Bool false -> !^"false"
  | Number value -> pp_expr value
  | Number_Int _ -> assert false
  | Number_IntLimit ("MAX", t) -> pp_expr (c_int_type_op t "max_val" [])
  | Number_IntLimit ("MIN", t) -> pp_expr (c_int_type_op t "min_val" [])
  | Number_IntLimit _ -> failwith "Only support min or max for limit parameter"
  | Number_Float q -> !^(Q.to_string q)
  | String s -> dquotes !^s
  | Symbol id -> !^id
  | Field (k, v) -> pp_expr k ^^ dot ^^ pp_expr v
  | Call (f, args) ->
    pp_expr f ^^ parens (separate_map (comma ^^ break 1) pp_expr args |> align |> group)
  | Function (args, body, _) -> pp_fn args body
  | Table (members, _) ->
    let field = function
      | Named (k, v) -> !^k ^^ !^" = " ^^ pp_expr v
      | List v -> pp_expr v
    and sep = comma ^^ break 1 in
    surround_separate_map indent 1 !^"{}" !^"{" sep !^"}" field members
  | TableGet (tbl, key) -> pp_expr tbl ^^ brackets (pp_expr key)
  | TableSet (tbl, key, value) ->
    pp_expr (TableGet (tbl, key)) ^^ !^" = " ^^ pp_expr value
  | Binary args ->
    let res =
      match args with
      | Or (a, b) -> infix 0 1 !^"or" (pp_expr a) (pp_expr b)
      | And (a, b) -> infix 0 1 !^"and" (pp_expr a) (pp_expr b)
      | AddI (a, b) -> infix 2 1 !^"+" (pp_expr a) (pp_expr b)
      | Add (a, b, t) -> pp_expr (Normalise (Binary (AddI (a, b)), t))
      | SubtractI (a, b) -> infix 2 1 !^"-" (pp_expr a) (pp_expr b)
      | Subtract (a, b, t) -> pp_expr (Normalise (Binary (SubtractI (a, b)), t))
      | MultiplyI (a, b) -> infix 2 1 !^"*" (pp_expr a) (pp_expr b)
      | Multiply (a, b, t) -> pp_expr (Normalise (Binary (MultiplyI (a, b)), t))
      | IntegerDivide (a, b, t) -> pp_expr (c_int_type_op t "div" [ a; b ])
      | FloatDivide (_a, _b) -> failwith "Float Divide not supported yet"
      | Exp (a, b, t) -> pp_expr (c_int_type_op t "exp" [ a; b ])
      | Remainder (a, b, t) -> pp_expr (Normalise (Call (Symbol "fmod", [ a; b ]), t))
      | Modulo (a, b, t) -> pp_expr (c_int_type_op t "mod" [ a; b ])
      | LessThan (a, b, ("i8" | "i16" | "i32" | "i64")) ->
        infix 2 1 !^"<" (pp_expr a) (pp_expr b)
      | LessThan (a, b, _) -> pp_expr (Call (Symbol "ult", [ a; b ]))
      | LessThanOrEqTo (a, b, t) -> pp_expr (Unary (Not (Binary (LessThan (b, a, t)))))
      | Min (a, b, t) -> pp_expr (c_int_type_op t "min" [ a; b ])
      | Max (a, b, t) -> pp_expr (c_int_type_op t "max" [ a; b ])
      | BW_Xor (a, b, _) -> infix 2 1 !^"~" (pp_expr a) (pp_expr b)
      | BW_And (a, b, _) -> infix 2 1 !^"&" (pp_expr a) (pp_expr b)
      | BW_Or (a, b, _) -> infix 2 1 !^"|" (pp_expr a) (pp_expr b)
      | LeftShift (a, b, _) -> infix 2 1 !^"<<" (pp_expr a) (pp_expr b)
      | RightShift (a, b, ("u8" | "u16" | "u32" | "u64")) ->
        infix 2 1 !^">>" (pp_expr a) (pp_expr b)
      | RightShift (a, b, t) -> pp_expr (c_int_type_op t "shr" [ a; b ])
      | Eq (a, b, true) -> infix 0 1 !^"==" (pp_expr a) (pp_expr b)
      | Eq (a, b, false) -> pp_expr (Call (Symbol "equals", [ a; b ]))
    in
    parens (align (group res))
  | Unary args ->
    let res =
      match args with
      | Not v -> prefix 1 1 !^"not" (pp_expr v)
      | Negate (v, _) -> prefix 1 1 !^"-" (pp_expr v)
      | BW_FLS v -> pp_expr (call_c_func "fls" [ v ])
      | BW_FLSL v -> pp_expr (call_c_func "flsl" [ v ])
      | BW_Complement (v, t) -> pp_expr (c_int_type_op t "bw_compl" [ v ])
    in
    parens (align (group res))
  | Normalise (expr, t) -> align (group (normalised (pp_expr expr) t))


and pp_stmt = function
  | Assign (id, None) -> !^id
  | Assign (id, Some x) -> !^id ^^ !^" = " ^^ pp_expr x
  | Block stmts -> surround indent 1 !^"do" (pp_block stmts) !^"end"
  | LocalAssign (id, expr) -> !^"local " ^^ pp_stmt (Assign (id, expr))
  | FunctionDef (name, args, body, _) -> pp_fn ~name args body
  | LocalFunctionDef (name, args, body) -> !^"local " ^^ pp_fn ~name args body
  | FunctionCall (fn, args) -> pp_expr (Call (fn, args))
  | Return (Some x) -> !^"return " ^^ pp_expr x
  | Return None -> !^"return"
  | IfElse cases ->
    let clause hdr stmts = hdr ^^ nest indent (break 1 ^^ pp_block stmts) in
    let condition kw (cond, stmts) =
      clause (surround indent 1 kw (pp_expr cond) !^"then") stmts
    in
    let (RealIfElse (cons, alts, alt)) = the_real_if cases in
    let items =
      (condition !^"if" cons :: List.map (condition !^"elseif") alts)
      @ (match alt with Some stmts -> [ clause !^"else" stmts ] | _ -> [])
      @ [ !^"end" ]
    in
    separate (break 1) items |> align
  | SExpr expr -> pp_expr expr
  | While (cond, while_body) ->
    let hdr = surround indent 1 !^"while" (pp_expr cond) !^"do" in
    surround indent 1 hdr (pp_block while_body) !^"end"
  | LineBreak -> !^""
  | _ -> !^""


and pp_block stmts = separate_map hardline pp_stmt stmts

and pp_fn ?name args body =
  let hdr =
    !^"function "
    ^^ optional string name
    ^^ parens (separate_map (comma ^^ break 1) pp_expr args |> align |> group)
  in
  surround indent 1 hdr (pp_block body) !^"end" ^^ hardline


let to_string doc =
  let b = Buffer.create 117 in
  PPrint.ToBuffer.pretty 1. width b doc;
  Buffer.contents b


let pp_stmt s = (pp_stmt s |> to_string) ^ "\n"

let pp_expr s = pp_expr s |> to_string
