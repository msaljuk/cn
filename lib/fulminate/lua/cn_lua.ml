module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax
module PP = Pp_lua
open Utils

type lua_statements = (LuaS.stmt list)
type wrapper_function = (A.sigma_declaration * CF.GenTypes.genTypeCategory A.sigma_function_definition)
type wrapper_functions = (wrapper_function list)
type lua_cn_exec = (lua_statements * wrapper_functions)

let get_expr_str expr = PP.pp_expr expr

let cn_sym = LuaS.Symbol( "cn" )
let cn_spec_mode_sym = LuaS.Symbol( "cn.spec_mode" )
let cn_assert_sym = LuaS.Symbol( "cn.assert" )
let cn_asserts_table_sym = LuaS.Symbol( "cn.asserts" )
let cn_error_stack_push_sym = LuaS.Symbol( "cn.error_stack.push" )
let cn_error_stack_pop_sym  = LuaS.Symbol( "cn.error_stack.pop" )

let get_empty_lua_stmts : (LuaS.stmt list)
  = ([])

let get_empty_wrapper_functions : wrapper_functions
  = ([])

let get_empty_lua_cn_exec : lua_cn_exec =
  (get_empty_lua_stmts, get_empty_wrapper_functions)

let concat (exec_list : lua_cn_exec list) =
  let lua_stmts_list, wrapper_stmts_list = List.split exec_list in
  let merged_lua_stmts = List.concat lua_stmts_list in
  let merged_wrapper_stmts = List.concat wrapper_stmts_list in
  (merged_lua_stmts, merged_wrapper_stmts)

let generate_c_fn_wrapper_prefix (c_fn_name : Sym.t)
  = "lua_cn_" ^ (Sym.pp_string c_fn_name) ^ "_"

let generate_c_precondition_fn_wrapper_name (c_fn_name : Sym.t)
  = (generate_c_fn_wrapper_prefix c_fn_name) ^ ("precondition")

let generate_c_postcondition_fn_wrapper_name (c_fn_name : Sym.t)
  = (generate_c_fn_wrapper_prefix c_fn_name) ^ ("postcondition")

let generate_c_push_frame_fn_wrapper_name (c_fn_name : Sym.t)
  = (generate_c_fn_wrapper_prefix c_fn_name) ^ ("push_frame")

let generate_c_pop_frame_fn_wrapper_call
  : (CF.GenTypes.genTypeCategory A.statement_)
  =
  (A.(AilSexpr (
    mk_expr (A.(AilEcall (
      mk_expr (AilEident (Sym.fresh "lua_cn_frame_pop_function")), []))))))

let generate_c_fn_wrapper_def 
  (lua_fn_name : string)
  (wrapper_fn_name : string)
  (wrapper_fn_args : (CF.Ctype.union_tag * CF.Ctype.ctype) list)
  : wrapper_function
  = 
  (*
  Example 

  Input: 
  lua_fn_name: "cn.frames.push_function.arrow_access_1"
  wrapper_fn_name: "lua_cn_frame_push_function_arrow_access_1"
  wrapper_fn_params: [struct s** origin]
  
  output:
  void lua_cn_frame_push_function_arrow_access_1(struct s** origin)
  {
    lua_State* L = lua_get_state();

    lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
    lua_getfield(L, -1, "frames");
    lua_getfield(L, -1, "push_function");
    lua_getfield(L, -1, "arrow_access_1");

    lua_pushinteger(L, lua_convert_ptr_to_int(origin));

    if (lua_pcall(L, 1, 0, 0) != LUA_OK) {
        fprintf(stderr, "Error calling cn.frames.push_function.arrow_access_1: %s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
    }

    lua_pop(L, 2);
  }
  *)

  let call name args = 
    A.AilSexpr (mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args))) 
  in

  let var name = mk_expr (AilEident (Sym.fresh name)) in

  let int_const integer
    = 
    mk_expr (
      A.(AilEconst(
        ConstantInteger (IConstant (Z.of_int (integer), Decimal, None)))))
  in

  let str_expr string = 
    mk_expr (
      A.(AilEstr( 
        None , [Locations.other __LOC__, [ string ]] ))) 
  in

  let convert_args (input_args : (CF.Ctype.union_tag * CF.Ctype.ctype) list) 
    : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list =
      List.map (
        fun (tag, ctype) ->
          (
            (Sym.fresh ((Sym.pp_string tag) ^ "_addr")),
            (CF.Ctype.no_qualifiers, mk_ctype (CF.Ctype.Pointer (CF.Ctype.no_qualifiers, ctype)), false)
          )
      ) input_args
  in
  let arg_names, arg_types = List.split (convert_args wrapper_fn_args) in

  let lua_fn_field_names = List.tl (String.split_on_char '.' lua_fn_name) in
  let generate_getfield field_name =
    call "lua_getfield" [var "L"; int_const (-1); str_expr field_name];
  in

  let generate_arg_push arg_name =
    call "lua_pushinteger" [
        var "L"; 
        mk_expr (AilEcall (var "lua_convert_ptr_to_int", [var (Sym.pp_string arg_name)]))
      ];
  in

  let (body : CF.GenTypes.genTypeCategory A.statement list) = 
      List.map 
      mk_stmt
      (
        [ call "lua_rawgeti" [var "L"; var "LUA_REGISTRYINDEX"; mk_expr (AilEcall (var "lua_cn_get_runtime_ref", [])) ]]
        @ (List.map generate_getfield lua_fn_field_names)
        @ (List.map generate_arg_push arg_names)
        (*@saljuk TODO: Make this safer by checking the results of p_call and handling them *)
        @ [ call "lua_pcall" [var "L"; int_const (List.length arg_names); int_const (0); int_const (0) ]]
        @ [ call "lua_pop" [var "L"; int_const (List.length lua_fn_field_names - 1)] ]
      )
  in
  
  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let id = Sym.fresh wrapper_fn_name in

  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            ( false, ( CF.Ctype.no_qualifiers, CF.Ctype.void), arg_types, false, false, false )) ) 
    )
  in

  let def = 
    (id, (loc, 0, attrs, arg_names, (mk_stmt (A.AilSblock ([], body))))) 
  in

  (decl, def)

let generate_lua_filename basefile 
  = (Filename.remove_extension basefile) ^ ".lua"

let generate_lua_fn_prefix (c_fn_name : Sym.t)
  = (Pp_lua.pp_expr cn_sym) ^ (".") ^ (Sym.pp_string c_fn_name) ^ (".")

let generate_lua_precondition_fn_name (c_fn_name : Sym.t)
  = (generate_lua_fn_prefix c_fn_name) ^ ("precondition")

let generate_lua_postcondition_fn_name (c_fn_name : Sym.t)
  = (generate_lua_fn_prefix c_fn_name) ^ ("postcondition")

let generate_lua_push_frame_fn_name (c_fn_name : Sym.t)
  = (generate_lua_fn_prefix c_fn_name) ^ ("push_frame")

let generate_lua_runtime_core_req
  (* local cn = require("lua_cn_runtime_core") *)
  = (LuaS.LocalAssign(
        get_expr_str cn_sym,
        LuaS.Call( "require", [ LuaS.String("lua_cn_runtime_core") ] )
      ))

let generate_lua_cn_error_stack_push (msg: string)
  = (LuaS.FunctionCall(
      get_expr_str cn_error_stack_push_sym,
      [ LuaS.String(msg) ]))
let generate_lua_cn_error_stack_pop 
  = (LuaS.FunctionCall(
      get_expr_str cn_error_stack_pop_sym,
      []))

let generate_lua_cn_assert fn_name ail_expr error_msg
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
        [ LuaS.Bool(false); LuaS.Table(cn_spec_mode_sym, LuaS.Symbol("STATEMENT")) ]) in

    let body_stmts = [ error_push_stmt; assert_stmt; error_pop_stmt ] in

    let fn_name_table = LuaS.Table( cn_asserts_table_sym, LuaS.Symbol(fn_name) ) in

    let func_stmt = LuaS.FunctionDef( get_expr_str fn_name_table, [], body_stmts ) in

    ( func_stmt )
  ) else ( LuaS.Empty )
