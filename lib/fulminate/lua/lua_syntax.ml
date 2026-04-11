type ident = string

(* Lua Expressions *)
type expr =
  | Nil
  | Bool of bool
  | Number_Int of Z.t
  | Number_Float of Q.t
  | String of string
  | Symbol of ident
  | Field of expr * expr
  | Call of ident * expr list
  | Function of expr list * stmt list * bool       (* function(a, b) ... end - anonymous function *)
  | Table of table_field_type list * bool

and table_field_type =
  | Named of ident * expr                          (* { a = 5 } *)
  | List of expr                                   (* { 5, 6, 7 } *)

(* Lua Statements *)
and stmt =
  | Assign of ident * expr                         (* x = 10 *)
  | LocalAssign of ident * expr                    (* local x = 10 *)
  | FunctionDef of ident * expr list * stmt list   (* fn x(a, b) \n body \n end *)
  | FunctionCall of ident * expr list              (* assert(false) *)
  | Return of expr                                 (* return false *)
  | LocalTable of expr * expr list                 (* local x = { a = 5, b = 7 } *)
  | IfElse of expr * stmt list * stmt list         (* if(cond) then ... else ... *)
  | SExpr of expr                                  (* used to carry an expression as a statement (similar to A.AilSexpr) *)
  | Empty
