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
let cn_frames_push_fn_sym = LuaS.Symbol( "cn.frames.push_function" )
let cn_frames_set_local_sym = LuaS.Symbol( "cn.frames.set_local" )
let c_sym = LuaS.Symbol( "c" )
let c_sym_addr_suffix = "_addr"
let get_type_prefix = "get_"
let peek_type_prefix = "peek_"

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

let convert_c_args_to_wrapper_args (c_args :(CF.Ctype.union_tag * CF.Ctype.ctype) list) 
    : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list
    =
    List.map (
      fun (tag, ctype) ->
        (
          (Sym.fresh ((Sym.pp_string tag) ^ c_sym_addr_suffix)),
          (CF.Ctype.no_qualifiers, mk_ctype (CF.Ctype.Pointer (CF.Ctype.no_qualifiers, ctype)), false)
        )
    ) c_args

let c_sym_to_lua_sym (c_sym : CF.Ctype.union_tag)
  : LuaS.expr
  = 
  LuaS.Symbol(Sym.pp_string c_sym)

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
  (wrapper_fn_args : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list)
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

  let arg_names, arg_types = List.split wrapper_fn_args in

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


let generate_c_fn_get_struct 
  (struct_data : (A.ail_identifier *
        (Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition)))
  : wrapper_function
  =
  let struct_name, struct_members = struct_data in

  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let id = Sym.fresh (peek_type_prefix ^ (Sym.pp_string struct_name)) in
  
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let var_sym s = mk_expr (AilEident s) in
  let int_const i = mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None)))) in
  
  let sym_L = Sym.fresh "L" in
  let sym_ptr = Sym.fresh "ptr" in
  let sym_val = Sym.fresh "val" in
  
  let ty_int64 = CF.Ctype.(Ctype ([], Basic (Integer (Signed Intptr_t)))) in
  let ty_struct_s = CF.Ctype.(Ctype ([], Struct struct_name)) in
  let ty_struct_s_ptr = CF.Ctype.(Ctype ([], Pointer (CF.Ctype.no_qualifiers, ty_struct_s))) in

  let mk_binding ty = 
    ((loc, A.Automatic, false), None, CF.Ctype.no_qualifiers, ty) 
  in

  let block_bindings = [
    (sym_ptr, mk_binding ty_int64);
    (sym_val, mk_binding ty_struct_s_ptr)
  ] in

  let decl_ptr = mk_stmt (A.AilSdeclaration [
    (sym_ptr, Some (mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh "luaL_checkinteger")), [var_sym sym_L; int_const 1]))))
  ]) in

  let cast_expr = mk_expr (AilEcast (CF.Ctype.no_qualifiers, ty_struct_s_ptr, var_sym sym_ptr)) in
  let decl_val = mk_stmt (A.AilSdeclaration [
    (sym_val, Some cast_expr)
  ]) in

  let generate_lua_table_for_struct 
    (struct_members : Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition)
  =
    let push_int_expr_to_table ((key, value) : string * CF.GenTypes.genTypeCategory A.expression) =
      let key_expr = mk_expr (AilEstr(None, [(Locations.other __LOC__, [key])])) in
      let lua_expr = var_sym sym_L in
      [
        mk_stmt (A.AilSexpr (call "lua_pushstring" [ lua_expr; key_expr ]));
        mk_stmt (A.AilSexpr (call "lua_pushinteger" [ lua_expr; value ]));
        mk_stmt (A.AilSexpr (call "lua_settable" [ lua_expr; int_const (-3)]))
      ]
    in

    let generate_table_entry_for_member (member_name, _member_type) =
      let member_expr = mk_expr (AilEmemberofptr (var_sym sym_val, member_name)) in
      let addr_expr = mk_expr (AilEunary (Address, member_expr)) in
      let final_expr = mk_expr (
        AilEcall (
          mk_expr (AilEident (Sym.fresh "lua_convert_ptr_to_int")), 
          [addr_expr])
      ) in
      let table_key = 
        (CF.Pp_utils.to_plain_pretty_string (CF.Pp_symbol.pp_identifier member_name)  ^ c_sym_addr_suffix)
      in
      push_int_expr_to_table (table_key, final_expr)
    in

    let generate_struct_size_entry = 
      let table_key = "size" in
      let size_expr = mk_expr (AilEsizeof (CF.Ctype.no_qualifiers, ty_struct_s)) in
      push_int_expr_to_table (table_key, size_expr)
    in

    let _, _, tag_defs = struct_members in
    let member_names_and_types = 
      match tag_defs with
      | CF.Ctype.StructDef(tag_data_list, _) ->
          List.map (fun (id, (_, _, _, ctype)) -> (id, ctype)) tag_data_list
      | _ -> []
    in

    let new_table_stmt = mk_stmt (AilSexpr (call "lua_newtable" [ mk_expr (AilEident (sym_L)) ])) in

    (
      [ new_table_stmt ]
      @ (List.concat (List.map generate_table_entry_for_member member_names_and_types)
      @ generate_struct_size_entry)
    )
  in

  let ret_stmt = mk_stmt (AilSreturn (int_const (1))) in

  let lua_table_push = generate_lua_table_for_struct struct_members in

  let body_stmts = 
    [ decl_ptr; decl_val; ]
    @ lua_table_push
    @ [ ret_stmt ]
  in

  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in

  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            ( false, ( CF.Ctype.no_qualifiers, CF.Ctype.void), [], false, false, false )) ) 
    )
  in

  let def = 
    (id, (loc, 0, attrs, [], (final_body))) 
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

let generate_lua_push_frame_fn
  (lua_fn_name : string)
  (c_fn_args : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list)
  : LuaS.stmt
  = 

  (*@saljuk NOTE: Consider hoisting this out if we need to reuse this logic for pre/post/inline
  stmt parameter reading (most likely)*)
  let get_arg_expr
    (arg : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)))
    = 
    let get_fn_prefix = LuaS.Field(cn_sym, c_sym) in

    let c_symbol, (_, (c_addr_type : CF.Ctype.ctype), _) = arg in
    let c_type = get_ctype_without_ptr c_addr_type in

    let type_str = 
      let get_type type_str = get_type_prefix ^ type_str in
      let peek_type type_str = peek_type_prefix ^ type_str in

      (match (rm_ctype c_type) with
        | CF.Ctype.Basic (x) ->
          (match (x) with 
            | CF.Ctype.Integer (i_type) -> 
              (match i_type with
                | CF.Ctype.Bool -> get_type "bool";
                | CF.Ctype.Char -> get_type "char";
                (*@saljuk TODO: Revisit this in the future. *)
                | CF.Ctype.Signed (_) | CF.Ctype.Unsigned (_) -> get_type "integer";
                | CF.Ctype.Size_t -> get_type "size_t";
                | _ -> (""));
            | CF.Ctype.Floating (f_type) ->
              match f_type with
                | CF.Ctype.RealFloating (rf_type) ->
                  match rf_type with
                    | CF.Ctype.Float -> get_type "float";
                    | CF.Ctype.Double | CF.Ctype.LongDouble -> get_type "double");
        | CF.Ctype.Pointer (_, _) -> get_type "pointer";
        | CF.Ctype.Struct (s_sym) -> peek_type (Sym.pp_string s_sym);
        | _ -> "")
    in

    LuaS.Call(
      Pp_lua.pp_expr (LuaS.Field(get_fn_prefix, LuaS.Symbol(type_str))),
      [ c_sym_to_lua_sym c_symbol ] )
  in

  let get_args 
    = 
    List.map
    (fun (arg : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool))) -> (
      let get_sym_name_wo_addr_suffix sym =
        let sym_name_w_suffix = Sym.pp_string sym in
        let len_a = String.length sym_name_w_suffix in
        let len_b = String.length c_sym_addr_suffix in
        String.sub sym_name_w_suffix 0 (len_a - len_b)
      in

      let c_sym_w_addr, _ = arg in

      (LuaS.FunctionCall(
        Pp_lua.pp_expr cn_frames_set_local_sym,
        [
          LuaS.String(get_sym_name_wo_addr_suffix c_sym_w_addr);
          get_arg_expr arg
        ]
      ))
    ))
    c_fn_args
  in
  let initial_push_fn = [ LuaS.FunctionCall(Pp_lua.pp_expr cn_frames_push_fn_sym, []) ] in
  let lua_fn_body = initial_push_fn @ get_args in

  let get_arg_name
    (arg : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool))) 
    =
    let c_sym_with_addr, _ = arg in
    (LuaS.Symbol (Sym.pp_string c_sym_with_addr))
  in
  let lua_fn_args = List.map get_arg_name c_fn_args in

  (
    LuaS.FunctionDef(
      lua_fn_name,
      lua_fn_args,
      lua_fn_body
    )
  )

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
        [ LuaS.Bool(false); LuaS.Field(cn_spec_mode_sym, LuaS.Symbol("STATEMENT")) ]) in

    let body_stmts = [ error_push_stmt; assert_stmt; error_pop_stmt ] in

    let fn_name_table = LuaS.Field( cn_asserts_table_sym, LuaS.Symbol(fn_name) ) in

    let func_stmt = LuaS.FunctionDef( get_expr_str fn_name_table, [], body_stmts ) in

    ( func_stmt )
  ) else ( LuaS.Empty )
