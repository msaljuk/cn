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
 
(* Lua Statements *)
type stmt =
  | Assign of ident * expr                         (* x = 10 *)
  | LocalAssign of ident * expr                    (* local x = 10 *)
  | FunctionDef of ident * expr list * stmt list   (* fn x(a, b) \n body \n end *)
  | FunctionCall of ident * expr list              (* assert(false) *)
  | Return of expr                                 (* return false *)
  | Empty
