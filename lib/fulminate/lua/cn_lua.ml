module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax
module PP = Pp_lua
module BT = BaseTypes
module IT = IndexTerms
open Utils

type lua_expression = (LuaS.expr)
type lua_statement = (LuaS.stmt)
type lua_expressions = (lua_expression list)
type lua_statements = (lua_statement list)
type wrapper_function = (A.sigma_declaration * CF.GenTypes.genTypeCategory A.sigma_function_definition)
type wrapper_functions = (wrapper_function list)
type lua_cn_exec = (lua_statements * wrapper_functions * lua_expression)

(* Globals *)
(* List of all locals that have been set so far inside the Lua CN environment for the current frame *)
let frame_locals: (string * CF.Ctype.ctype) list ref = ref []

let get_expr_str expr = PP.pp_expr expr

let cn_sym = LuaS.Symbol( "cn" )
let cn_spec_mode_sym = LuaS.Symbol( "cn.spec_mode" )
let cn_assert_sym = LuaS.Symbol( "cn.assert" )
let cn_asserts_sym = LuaS.Symbol( "cn.asserts" )
let cn_error_stack_push_sym = LuaS.Symbol( "cn.error_stack.push" )
let cn_error_stack_pop_sym  = LuaS.Symbol( "cn.error_stack.pop" )
let cn_frames_get_local_sym = LuaS.Symbol( "cn.frames.get_local" )
let cn_frames_set_local_sym = LuaS.Symbol( "cn.frames.set_local" )
let cn_frames_push_fn_sym = LuaS.Symbol( "cn.frames.push_function" )
let c_sym = LuaS.Symbol( "c" )
let c_sym_addr_suffix = "_addr"
let get_type_prefix = "get_"
let peek_type_prefix = "peek_"

let get_empty_lua_expr : (lua_expression)
  = (LuaS.Nil)
let get_empty_lua_stmt : (lua_statement)
  = (LuaS.Empty)
let get_empty_lua_exprs : (lua_expressions)
  = ([])
let get_empty_lua_stmts : (lua_statements)
  = ([])
let get_empty_wrapper_functions : wrapper_functions
  = ([])

let get_empty_lua_cn_exec : lua_cn_exec =
  (get_empty_lua_stmts, get_empty_wrapper_functions, get_empty_lua_expr)

let concat (exec_list : lua_cn_exec list) =
  let lua_stmts_list, wrapper_stmts_list, lua_exprs = Utils.list_split_three exec_list in
  let merged_lua_stmts = List.concat lua_stmts_list in
  let merged_wrapper_stmts = List.concat wrapper_stmts_list in

  (* We only concat finalized execs - any halfway generated expression cannot be handled *)
  let _ = 
    List.exists 
    (fun y -> 
      match y with 
        LuaS.Nil -> false 
        | _ -> 
          (*@saljuk TODO: Eventually turn this assert on once all lua expressions are properly being generated *)
          true (*failwith "Cannot concat lua_cn_execs containing a live expression. Finalize or pop it first."*)
    )
    lua_exprs
  in

  (merged_lua_stmts, merged_wrapper_stmts, get_empty_lua_expr)

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

let push_expr_to_exec ((in_exec, expr) : lua_cn_exec * lua_expression)
  : lua_cn_exec
=
  let stmts, wrappers, _ = in_exec in
  (stmts, wrappers, expr)

let pop_expr_from_exec (in_exec : lua_cn_exec) 
  : lua_cn_exec * lua_expression
=
  let stmts, wrappers, expr = in_exec in
  ((stmts, wrappers, get_empty_lua_expr), expr)

let push_stmts_to_exec ((in_exec, stmts) : lua_cn_exec * lua_statements)
  : lua_cn_exec
=
  let stmts_pre, wrappers, expr = in_exec in
  (stmts_pre @ stmts, wrappers, expr)

let wrap_sym_for_lua (in_sym : Sym.t)
  : Sym.t
=   
  if (
  List.exists 
  (fun (local_name, _) -> String.equal (Sym.pp_string in_sym) local_name) 
  !frame_locals) then (
    let frame_getter_wrap = 
      LuaS.Call(Pp_lua.pp_expr cn_frames_get_local_sym, [ LuaS.String(Sym.pp_string in_sym) ])
    in
    Sym.fresh (Pp_lua.pp_expr frame_getter_wrap)
  ) else (
    in_sym
  )

let expr_to_string (expr : lua_expression)
  : string
= Pp_lua.pp_expr expr

let debug_print_stmts (stmts : lua_statements)
=
  (List.iter
  (fun (x : lua_statement) -> (print_endline (PP.pp_stmt x)))
  stmts)

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

let generate_c_assert_fn_wrapper_name (func_id : int)
  : string
  =
  let c_assert_sym = Sym.fresh "assert" in
  (generate_c_fn_wrapper_prefix c_assert_sym) ^ (string_of_int func_id)

let generate_c_assert_fn_wrapper_call (c_func_name : string)
  : (CF.GenTypes.genTypeCategory A.statement_)
  =
  (A.(AilSexpr (
      mk_expr (A.(AilEcall (
        mk_expr (AilEident (Sym.fresh c_func_name)), []))))))

let mk_binding sym ty
  : A.ail_identifier 
    * ((Cerb_location.t * A.storageDuration * bool) 
    * CF.Ctype.alignment option 
    * CF.Ctype.qualifiers 
    * CF.Ctype.ctype) = 
  (sym, ((Cerb_location.unknown, A.Automatic, false), None, CF.Ctype.no_qualifiers, ty))

let lua_init_function_generation () : unit
  =
  frame_locals := [];
  ()

let lua_set_frame_local 
  (local_name : string) 
  (local_type : CF.Ctype.ctype) 
  (local_value : lua_expression)
  : lua_statement
  =
  frame_locals := (local_name, local_type) :: !frame_locals;

  (*@saljuk HACK: One of the purposes of storing these locals is that we can find them later
  * to conduct useful operations like:
  * - wrap the locals with lua_getters (cn.frames.get_local("var")),
  * - or recover their original c types.
  * However, if we've already set a local, the next time we encounter it will be in its wrapped form
  * (cn.frames.get_local("var")). To make it easier to still extract var's type info, we also map
  * the wrapped form to the same type here. 
  *
  * TODO: Find a better solution (preferably one that doesn't involve string 
  * parsing the wrapped symbol.)
  *)
  let local_name_sym = Sym.fresh local_name in
  frame_locals := (Sym.pp_string (wrap_sym_for_lua local_name_sym), local_type) :: !frame_locals;

  (LuaS.FunctionCall(
    Pp_lua.pp_expr cn_frames_set_local_sym,
    [
      LuaS.String(local_name);
      local_value
    ]
  ))

let generate_c_get_lua_state
  =
  let sym_L = Sym.fresh "L" in

  let ty_lua_state = CF.Ctype.(Ctype ([], Struct (Sym.fresh "lua_State"))) in
  let ty_lua_state_ptr = CF.Ctype.(Ctype ([], Pointer (CF.Ctype.no_qualifiers, ty_lua_state))) in

  let binding = mk_binding sym_L ty_lua_state_ptr in
  let decl_stmt = 
      A.AilSdeclaration [
        (sym_L, Some (mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh "lua_get_state")), []))))
      ]
  in

  (binding, decl_stmt)

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

  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in

  let (body : CF.GenTypes.genTypeCategory A.statement list) = 
      List.map 
      mk_stmt
      (
        [ lua_state_ss ]
        @ [ call "lua_rawgeti" [var "L"; var "LUA_REGISTRYINDEX"; mk_expr (AilEcall (var "lua_cn_get_runtime_ref", [])) ]]
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
    (id, (loc, 0, attrs, arg_names, (mk_stmt (A.AilSblock ([ lua_state_bs; ], body))))) 
  in

  (decl, def)


let generate_c_fn_struct_size (struct_name : A.ail_identifier)
  : wrapper_function
  =
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let var_sym s = mk_expr (AilEident s) in
  let int_const i = mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None)))) in
  let str_expr s = mk_expr (A.AilEstr ( None,[ ( Locations.other __LOC__, [ Sym.pp_string s ]) ])) in

  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in 
  let id = Sym.fresh ("push_" ^ (Sym.pp_string struct_name) ^ ("_size")) in

  let sym_L = Sym.fresh "L" in
  let sym_c = Sym.fresh "c" in
  let sym_sizeof = Sym.fresh "sizeof" in
  let sym_lua_registry_idx = Sym.fresh "LUA_REGISTRYINDEX" in
  let sym_lua_get_cn_ref = Sym.fresh "lua_cn_get_runtime_ref" in

  let ty_struct_s = CF.Ctype.(Ctype ([], Struct struct_name)) in

  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            ( false, ( CF.Ctype.no_qualifiers, CF.Ctype.signed_int), [], false, false, false )) ) 
    )
  in

  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in

  let body_stmts = 
    let size_expr = mk_expr (AilEsizeof (CF.Ctype.no_qualifiers, ty_struct_s)) in
    let lua_cn_ref = call (Sym.pp_string sym_lua_get_cn_ref) [] in
    let lua_expression = var_sym sym_L in
    ([
      mk_stmt lua_state_ss;
      mk_stmt (A.AilSexpr (call "lua_rawgeti" [ lua_expression ; var_sym sym_lua_registry_idx ; lua_cn_ref ]));
      mk_stmt (A.AilSexpr (call "lua_getfield" [ lua_expression ; int_const(-1) ; str_expr sym_c ]));
      mk_stmt (A.AilSexpr (call "lua_getfield" [ lua_expression ; int_const(-1) ; str_expr sym_sizeof ]));
      mk_stmt (A.AilSexpr (call "lua_pushinteger" [ lua_expression ; size_expr ]));
      mk_stmt (A.AilSexpr (call "lua_setfield" [ lua_expression ; int_const(-2); str_expr struct_name ]));
      mk_stmt (A.AilSexpr (call "lua_pop" [ lua_expression ; int_const(3) ]));
      mk_stmt (AilSreturn (int_const (1)));
    ])
  in

  let block_bindings = [
    lua_state_bs;
  ] in

  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in

  let def = 
    (id, (loc, 0, attrs, [], ( final_body ))) 
  in

  (decl, def)

let generate_c_fn_peek_struct 
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
      let lua_expression = var_sym sym_L in
      [
        mk_stmt (A.AilSexpr (call "lua_pushstring" [ lua_expression; key_expr ]));
        mk_stmt (A.AilSexpr (call "lua_pushinteger" [ lua_expression; value ]));
        mk_stmt (A.AilSexpr (call "lua_settable" [ lua_expression; int_const (-3)]))
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
      @ (List.concat (List.map generate_table_entry_for_member member_names_and_types))
    )
  in

  let ret_stmt = mk_stmt (AilSreturn (int_const (1))) in

  let lua_table_push = generate_lua_table_for_struct struct_members in

  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in

  let body_stmts = 
    [ mk_stmt lua_state_ss ]
    @ [ decl_ptr; decl_val; ]
    @ lua_table_push
    @ [ ret_stmt ]
  in

  let block_bindings = [
    lua_state_bs;
    mk_binding sym_ptr ty_int64;
    mk_binding sym_val ty_struct_s_ptr;
  ] in

  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in

  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            ( false, ( CF.Ctype.no_qualifiers, CF.Ctype.signed_int), [], false, false, false )) ) 
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

let generate_lua_assert_fn_name (func_id : int)
  = Pp_lua.pp_expr (LuaS.Field(cn_asserts_sym, LuaS.Symbol("inst" ^ string_of_int func_id)))

let generate_lua_runtime_core_req
  (* local cn = require("lua_cn_runtime_core") *)
  = (LuaS.LocalAssign(
        get_expr_str cn_sym,
        LuaS.Call( "require", [ LuaS.String("lua_cn_runtime_core") ] )
      ))

let generate_lua_type_reader (c_type : CF.Ctype.ctype)
  =
  let type_str = 
    let get_type type_str = get_type_prefix ^ type_str in
    let peek_type type_str = peek_type_prefix ^ type_str in

    match (rm_ctype c_type) with
      | CF.Ctype.Basic (x) ->
        (match (x) with 
          | CF.Ctype.Integer (i_type) -> 
            (match i_type with
              | CF.Ctype.Bool -> get_type "bool"
              | CF.Ctype.Char -> get_type "char"
              (*@saljuk TODO: Revisit this in the future. *)
              | CF.Ctype.Signed (_) | CF.Ctype.Unsigned (_) -> get_type "integer"
              | CF.Ctype.Size_t -> get_type "size_t"
              | _ -> (""))
          | CF.Ctype.Floating (f_type) ->
            match f_type with
              | CF.Ctype.RealFloating (rf_type) ->
                match rf_type with
                  | CF.Ctype.Float -> get_type "float"
                  | CF.Ctype.Double | CF.Ctype.LongDouble -> get_type "double")
      | CF.Ctype.Pointer (_, _) -> get_type "pointer"
      | CF.Ctype.Struct (s_sym) -> peek_type (Sym.pp_string s_sym)
      | _ -> ""
  in
  LuaS.Field(LuaS.Field(cn_sym, c_sym), LuaS.Symbol(type_str))

let generate_lua_push_frame_fn
  (lua_fn_name : string)
  (c_fn_args : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list)
  : LuaS.stmt
  = 
  let get_arg_expr
    (arg : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)))
    = 
    let c_symbol, (_, (c_addr_type : CF.Ctype.ctype), _) = arg in
    let c_type = get_ctype_without_ptr c_addr_type in
    let reader_field = generate_lua_type_reader c_type in
    LuaS.Call( Pp_lua.pp_expr reader_field, [ c_sym_to_lua_sym c_symbol ] )
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

      let c_sym_w_addr, (_, c_type, _) = arg in

      lua_set_frame_local (get_sym_name_wo_addr_suffix c_sym_w_addr) c_type (get_arg_expr arg)
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

let generate_lua_spec_mode spec_mode_sym
  : lua_expression
=
  LuaS.Field(cn_spec_mode_sym, LuaS.Symbol(Sym.pp_string spec_mode_sym))
    
let generate_lua_cn_assert 
  (error_msg : string)
  (in_exec : lua_cn_exec)
  (spec_mode : CF.Ctype.union_tag)
  : (CF.GenTypes.genTypeCategory A.statement_ list * lua_cn_exec)
  = 
  (*
    @saljuk TODO Don't have func name here yet (will have to plumb down). For
    now, just generated a random value - BAD
  *)
  let func_id = Random.int 100 in
  (*
    @saljuk TODO: Don't hardcode this. Pull type spec_mode into a common file that we
    can include here
  *)
  let spec_mode_str = (Sym.pp_string spec_mode) in
  let inline_spec_mode = "STATEMENT" in 
  let is_inline = String.equal spec_mode_str inline_spec_mode in

  let c_wrapper_func_name = generate_c_assert_fn_wrapper_name func_id in
  let lua_func_name = generate_lua_assert_fn_name func_id in

  let c_wrapper_dec_and_def, c_wrapper_call
    = 
    if is_inline then (
      (
        [ generate_c_fn_wrapper_def lua_func_name c_wrapper_func_name [] ],
        [ generate_c_assert_fn_wrapper_call c_wrapper_func_name ]
      )
    ) else ([], [])
  in
  
  let exec', assert_expr = pop_expr_from_exec in_exec in

  (* Skip asserts if it's an assert(true) or a nil *)
  let should_assert = 
    match assert_expr with
      | LuaS.Bool b -> if b then false else true
      | LuaS.Nil -> false
      | _ -> true
  in

  if should_assert then (
    let push_err_stmt = generate_lua_cn_error_stack_push error_msg in
    let pop_err_stmt = generate_lua_cn_error_stack_pop in

    let spec_mode_field = generate_lua_spec_mode spec_mode in

    let core_stmt = 
      LuaS.FunctionCall(Pp_lua.pp_expr cn_assert_sym, [ assert_expr; spec_mode_field ]) 
    in

    let ls_initial =
      [
        push_err_stmt;
        core_stmt;
        pop_err_stmt;
      ]
    in

    let ls_final =
      if is_inline then (
        [ LuaS.FunctionDef(
          lua_func_name,
          [],
          ls_initial
        ) ]
      ) else (
        ls_initial
      )
    in

    let (cn_exec_for_assert : lua_cn_exec) 
      = ( ls_final, c_wrapper_dec_and_def, get_empty_lua_expr ) 
    in

    ( c_wrapper_call, concat [ exec'; cn_exec_for_assert; ])
  ) else (
    ([ ], exec')
  )

let generate_lua_resource_get in_exec
  : (lua_expression)
=
  let _, expr = pop_expr_from_exec in_exec in
  LuaS.Call(Pp_lua.pp_expr cn_frames_get_local_sym, [ LuaS.String(Pp_lua.pp_expr expr) ])

let generate_lua_cn_return (expr : lua_expression) (is_unit : bool)
  : LuaS.stmt
=
  if is_unit then (
    LuaS.Return(expr)
  ) else ( LuaS.Return(LuaS.Nil) )

let generate_lua_resource sym ctype in_exec
  : lua_cn_exec
=
  let exec, expr = pop_expr_from_exec in_exec in

  let stmt = match rm_ctype ctype with
    | CF.Ctype.Void -> LuaS.FunctionCall("", [ expr ])
    | _ -> 
      lua_set_frame_local (Sym.pp_string sym) ctype expr
  in

  (push_stmts_to_exec (exec, [ stmt ]))

(* ---------------------------------- *)
(*         Cn-to-Lua Terms            *)
(* ---------------------------------- *)

let cn_to_lua_const 
    (constant: IT.const)
    (_baseType : BT.t)
    : (lua_expression * bool)
=
  let lua_expression =
    match constant with
    | IT.Z z -> LuaS.Number_Int(z)
    | MemByte { alloc_id = _; value = i } ->
      LuaS.Number_Int(i)
    | Bits ((_sgn, _sz), i) ->
      LuaS.Number_Int(i)
    | Q q -> LuaS.Number_Float(q)
    | Pointer { alloc_id = _; addr = a } ->
      LuaS.Number_Int(a)
    | Alloc_id _ -> failwith (__LOC__ ^ ": TODO Alloc_id")
    | Bool b -> LuaS.Bool(b)
    | Unit -> LuaS.Nil
    | Null -> LuaS.Nil
    | CType_const _ -> failwith (__LOC__ ^ ": TODO CType_const")
    | Default _bt -> failwith (__LOC__ ^ ": TODO Default_const")
  in
  let is_unit = constant == Unit in
  (lua_expression, is_unit)

let cn_to_lua_sym (c_sym : CF.Ctype.union_tag)
  : (lua_expression)
=
  LuaS.Symbol(Sym.pp_string c_sym)

let cn_to_lua_binop (expr_a, expr_b, binop)
  : (lua_expression)
=
  let lua_expression =
    match binop with
    | IT.EQ | _ -> 
      let extracted_type_a = 
        let target_name = Pp_lua.pp_expr expr_a in
        match List.find_opt (fun (local_name, _) -> String.equal local_name target_name) !frame_locals with
        | Some (_, local_type) -> Some local_type
        | None -> None
      in

      let final_expr_a = 
        match extracted_type_a with
          | Some (c_type) ->
              LuaS.Call(
                Pp_lua.pp_expr (generate_lua_type_reader c_type),
                [ expr_a ])
          | None -> expr_a
      in

      LuaS.Call("cn.equals", [ final_expr_a; expr_b ])
  in
  (lua_expression)
  
let cn_to_lua_apply sym in_execs
  : (lua_cn_exec)
= 
  let execs_and_exprs = List.map pop_expr_from_exec in_execs in
  let execs, exprs = List.split execs_and_exprs in
  let apply_expr = LuaS.Call(Sym.pp_string sym, exprs) in
  let merged_execs = concat execs in
  let final_exec = push_expr_to_exec (merged_execs, apply_expr) in
  (final_exec)