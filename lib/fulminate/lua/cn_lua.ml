module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax
module PP = Pp_lua
open Utils

type lua_cn_exec = (LuaS.stmt list) * (CF.GenTypes.genTypeCategory A.statement_ list)

let get_expr_str expr = PP.pp_expr expr

let cn_sym = LuaS.Symbol( "cn" )
let cn_spec_mode_sym = LuaS.Symbol( "cn.spec_mode" )
let cn_assert_sym = LuaS.Symbol( "cn.assert" )
let cn_asserts_table_sym = LuaS.Symbol( "cn.asserts" )
let cn_error_stack_push_sym = LuaS.Symbol( "cn.error_stack.push" )
let cn_error_stack_pop_sym  = LuaS.Symbol( "cn.error_stack.pop" )

let get_empty_lua_cn_exec : lua_cn_exec =
  ([], [])

let concat exec_list =
  let lua_stmts_list, wrapper_stmts_list = List.split exec_list in
  let lua_stmts = List.concat lua_stmts_list in
  let wrapper_stmts = List.concat wrapper_stmts_list in
  (lua_stmts, wrapper_stmts)

let generate_lua_filename basefile 
  = (Filename.remove_extension basefile) ^ ".lua"

let generate_lua_runtime_core_req
  (* local cn = require("lua_cn_runtime_core") *)
  = (LuaS.LocalAssign(
        get_expr_str cn_sym,
        LuaS.Call( "require", [ LuaS.String("lua_cn_runtime_core") ] )
      ))

let generate_lua_cn_assert func_name ail_expr error_msg
  = 
  (* 
  @note saljuk: right now, only providing an implementation for assert(false) asserts.
  Need to discuss how to actually generate more complex asserts since the ail input already has
  'converted' cn inputs, whereas we need to propogate the original c datatypes.
  *)
  let is_false_assert =
    match rm_expr ail_expr with
    | A.(AilEcall (sym_ident, args)) ->
      let sym =
        match rm_expr sym_ident with
        | A.(AilEident sym') -> sym'
        | _ -> failwith (__FUNCTION__ ^ ": First argument to AilEcall must be AilEident")
      in
      if String.equal (Sym.pp_string sym) "convert_to_cn_bool" && List.non_empty args then (
        match rm_expr (List.hd args) with
        | A.(AilEconst (ConstantPredefined PConstantFalse)) -> true
        | _ -> false
      ) else
        false
    | _ -> false
  in

  if is_false_assert then (
    let error_push_stmt = LuaS.FunctionCall(get_expr_str cn_error_stack_push_sym, [ LuaS.String(error_msg) ]) in
    let error_pop_stmt = LuaS.FunctionCall(get_expr_str cn_error_stack_pop_sym, [ ]) in

    let assert_stmt = 
      LuaS.FunctionCall(
        get_expr_str cn_assert_sym, 
        [ LuaS.Bool(false); LuaS.Field(cn_spec_mode_sym, LuaS.Symbol("STATEMENT")) ]) in

    let body_stmts = [ error_push_stmt; assert_stmt; error_pop_stmt ] in

    let func_name_table = LuaS.Field( cn_asserts_table_sym, LuaS.Symbol(func_name) ) in

    let func_stmt = LuaS.FunctionDef( get_expr_str func_name_table, [], body_stmts ) in

    ( func_stmt )
  ) else ( LuaS.Empty )

let generate_lua_cn_error_stack_push (msg: string)
  = (LuaS.FunctionCall(
      get_expr_str cn_error_stack_push_sym,
      [ LuaS.String(msg) ]))
let generate_lua_cn_error_stack_pop 
  = (LuaS.FunctionCall(
      get_expr_str cn_error_stack_pop_sym,
      []))