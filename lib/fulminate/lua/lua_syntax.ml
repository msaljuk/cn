type ident = string

(* Lua Expressions *)
type expr =
  | Nil
  | Bool of bool
  | Number_Int of expr * string
  | Number_Float of Q.t
  | String of string
  | Symbol of ident
  | Field of expr * expr
  | Call of ident * expr list
  | Function of expr list * stmt list * bool                (* function(a, b) ... end - anonymous function *)
  | Table of table_field_type list * bool
  | Binary of binary_expr_type
  | Unary of unary_expr_type

and table_field_type =
  | Named of ident * expr                                   (* { a = 5 } *)
  | List of expr                                            (* { 5, 6, 7 } *)

and binary_expr_type =
  | And of expr * expr
  | Or of expr * expr
  | Add of expr * expr * string
  | Subtract of expr * expr * string
  | Multiply of expr * expr * string
  | IntegerDivide of expr * expr * string
  | FloatDivide of expr * expr
  | Exp of expr * expr * string
  | Remainder of expr * expr * string
  | Modulo of expr * expr * string
  | LessThan of expr * expr * string
  | LessThanOrEqTo of expr * expr * string
  | Min of expr * expr * string
  | Max of expr * expr * string
  | BW_Xor of expr * expr * string
  | BW_Or of expr * expr * string
  | BW_And of expr * expr * string
  | LeftShift of expr * expr * string
  | RightShift of expr * expr * string
  | Eq of expr * expr

and unary_expr_type =
  | Not of expr
  | Negate of expr * string
  | BW_FLS of expr
  | BW_FLSL of expr
  | BW_Complement of expr * string

(* Lua Statements *)
and stmt =
  | Assign of ident * expr option                           (* x = 10 *)
  | LocalAssign of ident * expr option                      (* local x = 10 *)
  | FunctionDef of ident * expr list * stmt list            (* function x(a, b) \n body \n end *)
  | LocalFunctionDef of ident * expr list * stmt list       (* local function x(a, b) \n body \n end *)
  | FunctionCall of ident * expr list                       (* assert(false) *)
  | Return of expr                                          (* return false *)
  | LocalTable of expr * expr list                          (* local x = { a = 5, b = 7 } *)
  | IfElse of (expr option * stmt list) list                (* if(cond) then ... else ... *)
  | SExpr of expr                                           (* used to carry an expression as a statement (similar to A.AilSexpr) *)
  | Empty
