module CF = Cerb_frontend
module A = CF.AilSyntax
module LuaS = Lua_syntax
module PP = Pp_lua
module BT = BaseTypes
module IT = IndexTerms
open Utils

type lua_expression = LuaS.expr

type lua_statement = LuaS.stmt

type lua_expressions = lua_expression list

type lua_statements = lua_statement list

type wrapper_function =
  A.sigma_declaration * CF.GenTypes.genTypeCategory A.sigma_function_definition

type wrapper_functions = wrapper_function list

type lua_cn_exec = lua_statements * wrapper_functions * lua_expression

let get_expr_str expr = PP.pp_expr expr

let get_type_prefix = "get_"

let push_type_prefix = "push_"

let cn_sym = LuaS.Symbol "cn"

let cn_spec_mode_var_sym = LuaS.Symbol "spec_mode"

let cn_loop_ownership_var_sym = LuaS.Symbol "loop_ownership"

let cn_env_sym = LuaS.Symbol "cn.env"

let cn_assert_sym = LuaS.Symbol "cn.assert"

let cn_inline_sym = LuaS.Symbol "cn.inline"

let cn_error_stack_push_sym = LuaS.Symbol "cn.error_stack.push"

let cn_error_stack_pop_sym = LuaS.Symbol "cn.error_stack.pop"

let cn_frames_push_fn_sym = LuaS.Symbol "cn.frames.push_function"

let cn_frames_pop_fn_sym = LuaS.Symbol "cn.frames.pop_function"

let cn_locals_sym = LuaS.Symbol "cn.locals"

let cn_globals_sym = LuaS.Symbol "cn.globals"

let cn_lemma_sym = LuaS.Symbol "cn.lemma"

let cn_owned_sym = LuaS.Symbol "owned"

let cn_get_or_put_ownership_sym = LuaS.Symbol "cn.ghost_state.get_or_put_ownership"

let cn_member_shift_sym = LuaS.Symbol "member_shift"

let cn_array_shift_sym = LuaS.Symbol "array_shift"

let cn_map_def_sym = LuaS.Symbol "cn.map_def"

let cn_sizeof_field_sym = LuaS.Symbol "cn.c.sizeof"

let cn_offsets_field_sym = LuaS.Symbol "cn.c.offsets"

let cn_get_field_prefix_sym = LuaS.Symbol "cn.c.get_"

let lua_c_number_library_sym = LuaS.Symbol "c_num"

let lua_c_number_unsigned_types = [ "u8"; "u16"; "u32"; "u64" ]

let lua_c_number_signed_types = [ "i8"; "i16"; "i32"; "i64" ]

let cn_generate_get_field_prefix_sym = LuaS.Symbol "cn.c.generate_get_"

let get_empty_lua_expr : lua_expression = LuaS.Nil

let get_empty_lua_stmt : lua_statement = LuaS.Empty

let get_empty_lua_exprs : lua_expressions = []

let get_empty_lua_stmts : lua_statements = []

let get_empty_wrapper_functions : wrapper_functions = []

let get_empty_lua_cn_exec : lua_cn_exec =
  (get_empty_lua_stmts, get_empty_wrapper_functions, get_empty_lua_expr)


let get_cn_globals_sym_prefix : lua_expression = cn_globals_sym

let make_local_assign (stmt : lua_statement) : lua_statement =
  match stmt with
  | LuaS.Assign (ident, expr_opt) -> LuaS.LocalAssign (ident, expr_opt)
  | _ -> stmt


let concat (exec_list : lua_cn_exec list) =
  let lua_stmts_list, wrapper_stmts_list, lua_exprs = Utils.list_split_three exec_list in
  let merged_lua_stmts = List.concat lua_stmts_list in
  let merged_wrapper_stmts = List.concat wrapper_stmts_list in
  (* We only concat finalized execs - any halfway generated expression cannot be handled *)
  let _ =
    List.exists
      (fun y ->
         match y with
         | LuaS.Nil -> false
         | _ ->
           (*@saljuk TODO: Eventually turn this assert on once all lua expressions are properly being generated *)
           true
         (*failwith "Cannot concat lua_cn_execs containing a live expression. Finalize or pop it first."*))
      lua_exprs
  in
  (merged_lua_stmts, merged_wrapper_stmts, get_empty_lua_expr)


let convert_c_args_to_wrapper_args (c_args : (CF.Ctype.union_tag * CF.Ctype.ctype) list)
  : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list
  =
  List.map (fun (tag, ctype) -> (tag, (CF.Ctype.no_qualifiers, ctype, false))) c_args


let push_expr_to_exec ((in_exec, expr) : lua_cn_exec * lua_expression) : lua_cn_exec =
  let stmts, wrappers, _ = in_exec in
  (stmts, wrappers, expr)


let pop_expr_from_exec (in_exec : lua_cn_exec) : lua_cn_exec * lua_expression =
  let stmts, wrappers, expr = in_exec in
  ((stmts, wrappers, get_empty_lua_expr), expr)


let push_stmts_to_exec ((in_exec, stmts) : lua_cn_exec * lua_statements) : lua_cn_exec =
  let stmts_pre, wrappers, expr = in_exec in
  (stmts_pre @ stmts, wrappers, expr)


let prepend_cn_local cn_var : string =
  Pp_lua.pp_expr cn_locals_sym ^ "." ^ Sym.pp_string cn_var


let stmt_to_string lua_statement : string = Pp_lua.pp_stmt lua_statement

let expr_to_string lua_expression : string = Pp_lua.pp_expr lua_expression

let convert (sym : CF.Ctype.union_tag) : lua_expression = LuaS.Symbol (Sym.pp_string sym)

let fix_for_reserve_words_str str =
  let replace_end input replacement =
    let re = Str.regexp {|\b\(\.?\)end\(\.?\)\b|} in
    Str.global_replace re (Format.sprintf {|%s%s%s|} {|\1|} replacement {|\2|}) input
  in
  replace_end str "end_"


let fix_for_reserve_words_sym sym =
  let sym_str = Sym.pp_string sym in
  Sym.fresh (fix_for_reserve_words_str sym_str)


let debug_print_stmts (stmts : lua_statements) =
  List.iter (fun (x : lua_statement) -> print_endline (PP.pp_stmt x)) stmts


let debug_print_exprs (exprs : lua_expressions) =
  List.iter (fun (x : lua_expression) -> print_endline (PP.pp_expr x)) exprs


let is_function_empty (func_body : lua_statement) : bool =
  match func_body with
  | LuaS.FunctionDef (_, _, body, _) -> List.is_empty body
  | _ -> false


let get_lua_c_int_type_str bt =
  match bt with
  | BT.Loc () | BT.Integer -> "i64"
  | BT.Bits (sign, size) ->
    let sign_str = match sign with BT.Signed -> "i" | BT.Unsigned -> "u" in
    let size_str = string_of_int size in
    sign_str ^ size_str
  | _ -> "incompatible"


let generate_c_fn_wrapper_name (c_fn_name : Sym.t) = "lua_cn_" ^ Sym.pp_string c_fn_name

let generate_c_fn_wrapper_prefix (c_fn_name : Sym.t) =
  generate_c_fn_wrapper_name c_fn_name ^ "_"


let generate_c_precondition_fn_wrapper_name (c_fn_name : Sym.t) =
  generate_c_fn_wrapper_prefix c_fn_name ^ "precondition"


let generate_c_postcondition_fn_wrapper_name (c_fn_name : Sym.t) =
  generate_c_fn_wrapper_prefix c_fn_name ^ "postcondition"


let generate_c_push_globals_fn_wrapper_name = "lua_cn_push_globals"

let generate_c_push_array_fn_name arr_type = "lua_cn_push_" ^ arr_type ^ "_array"

let generate_c_push_frame_fn_wrapper_name (c_fn_name : Sym.t) =
  generate_c_fn_wrapper_prefix c_fn_name ^ "push_frame"


let generate_c_pop_frame_fn_wrapper_call : CF.GenTypes.genTypeCategory A.statement_ =
  A.(
    AilSexpr
      (mk_expr
         A.(AilEcall (mk_expr (AilEident (Sym.fresh "lua_cn_frame_pop_function")), []))))


let generate_c_inline_fn_wrapper_name (func_id : Sym.t) : string =
  generate_c_fn_wrapper_prefix (Sym.fresh "inline") ^ Sym.pp_string func_id


let generate_c_inline_fn_wrapper_call
      (c_func_name : string)
      (args : (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list)
  : CF.GenTypes.genTypeCategory A.statement_
  =
  let args_expr = List.map (fun (sym, _) -> mk_expr (AilEident sym)) args in
  A.(
    AilSexpr
      (mk_expr A.(AilEcall (mk_expr (AilEident (Sym.fresh c_func_name)), args_expr))))


let mk_binding sym ty
  : A.ail_identifier
    * ((Cerb_location.t * A.storageDuration * bool)
      * CF.Ctype.alignment option
      * CF.Ctype.qualifiers
      * CF.Ctype.ctype)
  =
  (sym, ((Cerb_location.unknown, A.Automatic, false), None, CF.Ctype.no_qualifiers, ty))


let generate_c_get_lua_state =
  let sym_L = Sym.fresh "L" in
  let ty_lua_state = CF.Ctype.(Ctype ([], Struct (Sym.fresh "lua_State"))) in
  let ty_lua_state_ptr =
    CF.Ctype.(Ctype ([], Pointer (CF.Ctype.no_qualifiers, ty_lua_state)))
  in
  let binding = mk_binding sym_L ty_lua_state_ptr in
  let decl_stmt =
    A.AilSdeclaration
      [ ( sym_L,
          Some (mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh "lua_get_state")), [])))
        )
      ]
  in
  (binding, decl_stmt)


let generate_lua_default_map_name (sym : CF.Ctype.union_tag) : string =
  "default_" ^ Sym.pp_string sym


let generate_lua_cn_empty_table : lua_expression = LuaS.Table ([], false)

let generate_lua_ctype_symbol (ctype : CF.Ctype.ctype) : lua_expression =
  let get_ctype_str in_ctype =
    CF.Pp_utils.to_plain_pretty_string
      (CF.Pp_ail.pp_ctype CF.Ctype.no_qualifiers in_ctype)
  in
  let rec sym ctype =
    match rm_ctype ctype with
    | CF.Ctype.Basic x ->
      (match x with
       | CF.Ctype.Integer i_type ->
         (match i_type with
          | CF.Ctype.Bool -> LuaS.Symbol "bool"
          (*@saljuk TODO: Buddy allocator uses char for number types 
           but not sure if that'll always be the case *)
          | CF.Ctype.Char -> LuaS.Symbol "u_8"
          (*@saljuk TODO: Flesh more of Signed/Unsigned out. *)
          | CF.Ctype.Signed s ->
            (match s with Long | LongLong -> LuaS.Symbol "long" | _ -> LuaS.Symbol "int")
          | CF.Ctype.Unsigned y ->
            let unsigned_prefix = "u_" in
            (match y with
             | CF.Ctype.Ichar -> LuaS.Symbol (unsigned_prefix ^ "8")
             | CF.Ctype.Long -> LuaS.Symbol (unsigned_prefix ^ "long")
             | _ -> LuaS.Symbol (unsigned_prefix ^ "int"))
          | _ -> failwith "Unsupported ctype. Could not get lua symbol")
       | CF.Ctype.Floating f_type ->
         (match f_type with
          | CF.Ctype.RealFloating rf_type ->
            (match rf_type with
             | CF.Ctype.Float -> LuaS.Symbol "float"
             | _ -> failwith "Unsupported ctype. Could not get lua symbol")))
    | CF.Ctype.Pointer (_, _) -> LuaS.Symbol "pointer"
    | CF.Ctype.Struct s_sym -> LuaS.Symbol (Sym.pp_string s_sym)
    | CF.Ctype.Array (array_c_type, size_opt) ->
      let c_type_sym = sym array_c_type in
      let size = Option.value ~default:Z.zero size_opt in
      LuaS.Call
        ( "array",
          [ LuaS.String (Pp_lua.pp_expr c_type_sym);
            LuaS.Number_Int (LuaS.Symbol (Z.to_string size), "u64")
          ] )
      (*failwith ("Unsupported type. Could not get lua symbol for type " ^ (get_ctype_str array_c_type)
       ^ "and size " ^ Z.to_string (Option.value ~default:Z.minus_one size_opt))*)
    | _ ->
      failwith
        ("Unsupported type. Could not get lua symbol for type " ^ get_ctype_str ctype)
  in
  sym ctype


let generate_lua_ctype_default_value (ctype : CF.Ctype.ctype) : lua_expression =
  let zero_sym = LuaS.Symbol "0" in
  let default_value ctype =
    match rm_ctype ctype with
    | CF.Ctype.Basic x ->
      (match x with
       | CF.Ctype.Integer i_type ->
         (match i_type with
          | CF.Ctype.Bool -> LuaS.Bool false
          | CF.Ctype.Char -> LuaS.Number_Int (zero_sym, "u8")
          | CF.Ctype.Signed s ->
            (match s with
             | Long | LongLong -> LuaS.Number_Int (zero_sym, "long")
             | _ -> LuaS.Number_Int (zero_sym, "i64"))
          | CF.Ctype.Unsigned y ->
            let unsigned_prefix = "u" in
            (match y with
             | CF.Ctype.Ichar -> LuaS.Number_Int (zero_sym, unsigned_prefix ^ "8")
             | CF.Ctype.Long -> LuaS.Number_Int (zero_sym, unsigned_prefix ^ "64")
             | _ -> LuaS.Number_Int (zero_sym, unsigned_prefix ^ "32"))
          | _ -> failwith "Unsupported ctype. Could not get default value for ctype")
       | CF.Ctype.Floating f_type ->
         (match f_type with
          | CF.Ctype.RealFloating rf_type ->
            (match rf_type with
             | CF.Ctype.Float -> LuaS.Number_Float Q.zero
             | _ -> failwith "Unsupported ctype. Could not default value for ctype")))
    | CF.Ctype.Pointer (_, _) -> LuaS.Number_Int (zero_sym, "u64")
    | CF.Ctype.Struct s_sym -> LuaS.Symbol (generate_lua_default_map_name s_sym)
    | CF.Ctype.Array (_, _) -> generate_lua_cn_empty_table
    | _ -> failwith "Unsupported type. Could not get default value for ctype"
  in
  default_value ctype


let generate_c_push_field_into_lua
      (lua_state_expr : CF.GenTypes.genTypeCategory A.expression)
      (c_field_expr : CF.GenTypes.genTypeCategory A.expression)
      (c_type : CF.Ctype.ctype)
  : CF.GenTypes.genTypeCategory A.expression
  =
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let int_const i =
    mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None))))
  in
  let final_expr =
    match rm_ctype c_type with
    | CF.Ctype.Basic x ->
      (match x with
       | CF.Ctype.Integer i_type ->
         (match i_type with
          (* Since 'bools' in C are just typedefs as some version of a integer, we maintain there 
           since some cn specs make comparisons to integers
          *)
          | CF.Ctype.Bool -> call "lua_pushinteger" [ lua_state_expr; c_field_expr ]
          | CF.Ctype.Char ->
            call "lua_pushlstring" [ lua_state_expr; c_field_expr; int_const 1 ]
          | CF.Ctype.Signed _ | CF.Ctype.Unsigned _ | CF.Ctype.Size_t ->
            call "lua_pushinteger" [ lua_state_expr; c_field_expr ]
          | _ -> failwith "Unsupported type. Cannot push field into lua")
       | CF.Ctype.Floating f_type ->
         (match f_type with
          | CF.Ctype.RealFloating rf_type ->
            (match rf_type with
             | CF.Ctype.Float | CF.Ctype.Double | CF.Ctype.LongDouble ->
               call "lua_pushfloat" [ lua_state_expr; c_field_expr ])))
    | CF.Ctype.Pointer (_, _) ->
      call
        "lua_pushinteger"
        [ lua_state_expr; call "lua_convert_ptr_to_int" [ c_field_expr ] ]
    | CF.Ctype.Struct s_sym ->
      let addressof_field = A.AilEunary (Address, c_field_expr) in
      call ("lua_cn_push_" ^ Sym.pp_string s_sym) [ mk_expr addressof_field ]
    | CF.Ctype.Array (arr_c_type, arr_size_opt) ->
      let arr_c_type_expr = generate_lua_ctype_symbol arr_c_type in
      let arr_size = Option.value ~default:Z.zero arr_size_opt in
      call
        (generate_c_push_array_fn_name (Pp_lua.pp_expr arr_c_type_expr))
        [ c_field_expr; int_const (Z.to_int arr_size) ]
    | _ -> failwith "Unsupported type. Cannot push field into lua"
  in
  final_expr


let generate_c_fn_wrapper_def
      (lua_fn_name : string)
      (wrapper_fn_name : string)
      (wrapper_fn_args :
        (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list)
      ?(global = false)
      ()
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
  let call_expr name args =
    mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args))
  in
  let call name args = A.AilSexpr (call_expr name args) in
  let var name = mk_expr (AilEident (Sym.fresh name)) in
  let string str = mk_expr (AilEstr (None, [ (Locations.other __LOC__, [ str ]) ])) in
  let int_const integer =
    mk_expr A.(AilEconst (ConstantInteger (IConstant (Z.of_int integer, Decimal, None))))
  in
  let str_expr string =
    mk_expr A.(AilEstr (None, [ (Locations.other __LOC__, [ string ]) ]))
  in
  let arg_names, arg_types = List.split wrapper_fn_args in
  let lua_state_expr = var "L" in
  let lua_fn_field_names = List.tl (String.split_on_char '.' lua_fn_name) in
  let pcall cond =
    A.(
      AilSif
        ( cond,
          mk_stmt
            (AilSblock
               ( [],
                 List.map
                   mk_stmt
                   [ call
                       "fprintf"
                       [ var "stderr";
                         string "LUA PCALL ERROR: %s\\n";
                         call_expr "lua_tostring" [ lua_state_expr; int_const (-1) ]
                       ];
                     call
                       "lua_pop"
                       [ lua_state_expr; int_const (List.length lua_fn_field_names - 1) ];
                     call "lua_cn_abort" []
                   ] )),
          mk_stmt (AilSblock ([], [ mk_stmt AilSskip ])) ))
  in
  let generate_getfield field_name =
    call "lua_getfield" [ lua_state_expr; int_const (-1); str_expr field_name ]
  in
  let generate_arg_push
        (wrapper_fn_arg :
          A.ail_identifier * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool))
    =
    let arg_name, arg_type = wrapper_fn_arg in
    let arg_name_expr =
      let base = var (Sym.pp_string arg_name) in
      if global then
        mk_expr (A.AilEunary (Address, base))
      else
        base
    in
    let arg_ctype =
      let _, base, _ = arg_type in
      if global then
        mk_ctype CF.Ctype.(Pointer (CF.Ctype.no_qualifiers, base))
      else
        base
    in
    A.AilSexpr (generate_c_push_field_into_lua lua_state_expr arg_name_expr arg_ctype)
  in
  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in
  let pcall_if_expr =
    call_expr
      "lua_pcall"
      [ lua_state_expr;
        int_const (List.length wrapper_fn_args);
        int_const 0;
        int_const 0
      ]
  in
  let (body : CF.GenTypes.genTypeCategory A.statement list) =
    List.map
      mk_stmt
      ([ lua_state_ss ]
       @ [ call
             "lua_rawgeti"
             [ lua_state_expr;
               var "LUA_REGISTRYINDEX";
               mk_expr (AilEcall (var "lua_cn_get_runtime_ref", []))
             ]
         ]
       @ List.map generate_getfield lua_fn_field_names
       @ List.map generate_arg_push wrapper_fn_args
       @ [ pcall pcall_if_expr ]
       @ [ call
             "lua_pop"
             [ lua_state_expr; int_const (List.length lua_fn_field_names - 1) ]
         ])
  in
  let prototype_arg_names, prototype_arg_types =
    if global then ([], []) else (arg_names, arg_types)
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
            ( false,
              (CF.Ctype.no_qualifiers, CF.Ctype.void),
              prototype_arg_types,
              false,
              false,
              false )) ) )
  in
  let def =
    ( id,
      (loc, 0, attrs, prototype_arg_names, mk_stmt (A.AilSblock ([ lua_state_bs ], body)))
    )
  in
  (decl, def)


let generate_c_fn_push_struct_size (struct_name : A.ail_identifier) : wrapper_function =
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let var_sym s = mk_expr (AilEident s) in
  let int_const i =
    mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None))))
  in
  let str_expr s =
    mk_expr (A.AilEstr (None, [ (Locations.other __LOC__, [ Sym.pp_string s ]) ]))
  in
  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let fn_sym = Sym.fresh ("push_" ^ Sym.pp_string struct_name ^ "_size") in
  let id = Sym.fresh (generate_c_fn_wrapper_name fn_sym) in
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
            (false, (CF.Ctype.no_qualifiers, CF.Ctype.signed_int), [], false, false, false))
      ) )
  in
  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in
  let body_stmts =
    let size_expr = mk_expr (AilEsizeof (CF.Ctype.no_qualifiers, ty_struct_s)) in
    let lua_cn_ref = call (Sym.pp_string sym_lua_get_cn_ref) [] in
    let lua_expression = var_sym sym_L in
    [ mk_stmt lua_state_ss;
      mk_stmt
        (A.AilSexpr
           (call
              "lua_rawgeti"
              [ lua_expression; var_sym sym_lua_registry_idx; lua_cn_ref ]));
      mk_stmt
        (A.AilSexpr
           (call "lua_getfield" [ lua_expression; int_const (-1); str_expr sym_c ]));
      mk_stmt
        (A.AilSexpr
           (call "lua_getfield" [ lua_expression; int_const (-1); str_expr sym_sizeof ]));
      mk_stmt (A.AilSexpr (call "lua_pushinteger" [ lua_expression; size_expr ]));
      mk_stmt
        (A.AilSexpr
           (call "lua_setfield" [ lua_expression; int_const (-2); str_expr struct_name ]));
      mk_stmt (A.AilSexpr (call "lua_pop" [ lua_expression; int_const 3 ]));
      mk_stmt (AilSreturn (int_const 1))
    ]
  in
  let block_bindings = [ lua_state_bs ] in
  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in
  let def = (id, (loc, 0, attrs, [], final_body)) in
  (decl, def)


let generate_c_fn_push_struct_name (struct_name : A.ail_identifier) : string =
  let fn_sym = Sym.fresh (push_type_prefix ^ Sym.pp_string struct_name) in
  generate_c_fn_wrapper_name fn_sym


let generate_c_fn_push_struct_offsets
      (struct_data :
        A.ail_identifier
        * (Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition))
  : wrapper_function
    (*
       struct lua_State* L = lua_get_state();
  lua_rawgeti(L, LUA_REGISTRYINDEX, lua_cn_get_runtime_ref());
  lua_getfield(L, -1, "c");
  lua_getfield(L, -1, "offsets");

  lua_newtable(L);
  lua_pushinteger(L, offsetof(struct s, a));
  lua_setfield(L, -2, "a");
  lua_pushinteger(L, offsetof(struct s, b));
  lua_setfield(L, -2, "b");
  lua_pushinteger(L, offsetof(struct s, s));
  lua_setfield(L, -2, "s");

  lua_setfield(L, -2, "s");
  lua_pop(L, 3);
    *)
  =
  let struct_name, struct_members = struct_data in
  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let id_prefix = generate_c_fn_push_struct_name struct_name in
  let id = Sym.fresh (id_prefix ^ "_offsets") in
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let var_sym s = mk_expr (AilEident s) in
  let int_const i =
    mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None))))
  in
  let str_expr s = mk_expr (A.AilEstr (None, [ (Locations.other __LOC__, [ s ]) ])) in
  let sym_L = Sym.fresh "L" in
  let expr_L = var_sym sym_L in
  let call_get_field index field =
    call "lua_getfield" [ expr_L; int_const index; field ]
  in
  let call_set_field index field =
    call "lua_setfield" [ expr_L; int_const index; field ]
  in
  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in
  let preamble =
    List.map
      mk_stmt
      [ lua_state_ss;
        A.AilSexpr
          (call
             "lua_rawgeti"
             [ expr_L;
               var_sym (Sym.fresh "LUA_REGISTRYINDEX");
               call "lua_cn_get_runtime_ref" []
             ]);
        A.AilSexpr (call_get_field (-1) (str_expr "c"));
        A.AilSexpr (call_get_field (-1) (str_expr "offsets"))
      ]
  in
  let generate_lua_table_for_struct_offsets
        (struct_members : Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition)
    =
    let generate_table_entry_for_member
          ((member_name, _) : CF.Symbol.identifier * CF.Ctype.ctype)
      =
      let member_name_string =
        CF.Pp_utils.to_plain_pretty_string (CF.Pp_symbol.pp_identifier member_name)
      in
      let member_name_as_string_expr =
        mk_expr (AilEstr (None, [ (loc, [ member_name_string ]) ]))
      in
      let offset_of_expr =
        call
          "offsetof"
          [ mk_expr (AilEident (Sym.fresh ("struct " ^ Sym.pp_string struct_name)));
            mk_expr (AilEident (Sym.fresh member_name_string))
          ]
      in
      [ mk_stmt (A.AilSexpr (call "lua_pushinteger" [ expr_L; offset_of_expr ]));
        mk_stmt (A.AilSexpr (call_set_field (-2) member_name_as_string_expr))
      ]
    in
    let _, _, tag_defs = struct_members in
    let member_names_and_types =
      match tag_defs with
      | CF.Ctype.StructDef (tag_data_list, _) ->
        List.map (fun (id, (_, _, _, ctype)) -> (id, ctype)) tag_data_list
      | _ -> []
    in
    let new_table_stmt =
      mk_stmt (AilSexpr (call "lua_newtable" [ mk_expr (AilEident sym_L) ]))
    in
    [ new_table_stmt ]
    @ List.concat (List.map generate_table_entry_for_member member_names_and_types)
  in
  let lua_table_push = generate_lua_table_for_struct_offsets struct_members in
  let epilogue =
    List.map
      mk_stmt
      [ A.AilSexpr (call_set_field (-2) (str_expr (Sym.pp_string struct_name)));
        A.AilSexpr (call "lua_pop" [ expr_L; int_const 3 ])
      ]
  in
  let body_stmts = preamble @ lua_table_push @ epilogue in
  let block_bindings = [ lua_state_bs ] in
  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in
  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            (false, (CF.Ctype.no_qualifiers, CF.Ctype.void), [], false, false, false)) )
    )
  in
  let def = (id, (loc, 0, attrs, [], final_body)) in
  (decl, def)


let generate_c_fn_push_struct
      (struct_data :
        A.ail_identifier
        * (Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition))
  : wrapper_function
  =
  (*
     struct lua_State* L = lua_get_state();

  lua_newtable(L);

  lua_pushinteger(L, data->a);
  lua_setfield(L, -2, "a");

  lua_pushinteger(L, data->b);
  lua_setfield(L, -2, "b");

  lua_pushinteger(L, lua_convert_ptr_to_int(data->s));
  lua_setfield(L, -2, "s");
  *)
  let struct_name, struct_members = struct_data in
  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let id = Sym.fresh (generate_c_fn_push_struct_name struct_name) in
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let var_sym s = mk_expr (AilEident s) in
  let int_const i =
    mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None))))
  in
  let sym_L = Sym.fresh "L" in
  let sym_data = Sym.fresh "data" in
  let generate_lua_table_for_struct
        (struct_members : Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition)
    =
    let generate_table_entry_for_member (member_name, member_type) =
      let member_name_string =
        CF.Pp_utils.to_plain_pretty_string (CF.Pp_symbol.pp_identifier member_name)
      in
      let lua_expression = var_sym sym_L in
      let member_field_access =
        mk_expr A.(AilEmemberofptr (var_sym sym_data, Id.make loc member_name_string))
      in
      let lua_push_expr =
        generate_c_push_field_into_lua lua_expression member_field_access member_type
      in
      let key_expr = mk_expr (AilEstr (None, [ (loc, [ member_name_string ]) ])) in
      let lua_set_field_expr =
        call "lua_setfield" [ lua_expression; int_const (-2); key_expr ]
      in
      [ mk_stmt (A.AilSexpr lua_push_expr); mk_stmt (A.AilSexpr lua_set_field_expr) ]
    in
    let _, _, tag_defs = struct_members in
    let member_names_and_types =
      match tag_defs with
      | CF.Ctype.StructDef (tag_data_list, _) ->
        List.map (fun (id, (_, _, _, ctype)) -> (id, ctype)) tag_data_list
      | _ -> []
    in
    let new_table_stmt =
      mk_stmt (AilSexpr (call "lua_newtable" [ mk_expr (AilEident sym_L) ]))
    in
    [ new_table_stmt ]
    @ List.concat (List.map generate_table_entry_for_member member_names_and_types)
  in
  let lua_table_push = generate_lua_table_for_struct struct_members in
  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in
  let body_stmts = [ mk_stmt lua_state_ss ] @ lua_table_push in
  let block_bindings = [ lua_state_bs ] in
  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in
  let struct_ptr_type =
    mk_ctype
      CF.Ctype.(Pointer (CF.Ctype.no_qualifiers, mk_ctype CF.Ctype.(Struct struct_name)))
  in
  let struct_decl_type = (CF.Ctype.no_qualifiers, struct_ptr_type, false) in
  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            ( false,
              (CF.Ctype.no_qualifiers, CF.Ctype.void),
              [ struct_decl_type ],
              false,
              false,
              false )) ) )
  in
  let def = (id, (loc, 0, attrs, [ sym_data ], final_body)) in
  (decl, def)


let generate_c_fn_push_struct_array (struct_tag : A.ail_identifier) : wrapper_function =
  (*
     struct lua_State* L = lua_get_state();
  lua_createtable(lua_state, size, 0);
  int i = 0;
  while (i < size) {
    lua_cn_push_<struct>(arr[i]);
    lua_rawseti(lua_state, -2, i);
    i++;
  }
  *)
  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let id = Sym.fresh (generate_c_push_array_fn_name (Sym.pp_string struct_tag)) in
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let var_sym s = mk_expr (AilEident s) in
  let int_const i =
    mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None))))
  in
  let sym_L = Sym.fresh "L" in
  let sym_arr = Sym.fresh "arr" in
  let sym_size = Sym.fresh "size" in
  let sym_i = Sym.fresh "i" in
  let mk_push_array_loop =
    let expr_i = var_sym sym_i in
    let cond_expr = mk_expr (A.AilEbinary (expr_i, A.Lt, var_sym sym_size)) in
    let incr_stmt = A.AilSexpr (mk_expr (A.AilEunary (A.PostfixIncr, expr_i))) in
    let body =
      let sym_call_fm = Sym.fresh (generate_c_fn_push_struct_name struct_tag) in
      let elem_exp =
        mk_expr (A.AilEbinary (var_sym sym_arr, A.Arithmetic A.Add, expr_i))
      in
      let push_call = A.AilSexpr (call (Sym.pp_string sym_call_fm) [ elem_exp ]) in
      let rawseti_call =
        A.AilSexpr (call "lua_rawseti" [ var_sym sym_L; int_const (-2); expr_i ])
      in
      mk_stmt (A.AilSblock ([], List.map mk_stmt [ push_call; rawseti_call; incr_stmt ]))
    in
    A.AilSwhile (cond_expr, body, 0)
  in
  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in
  let i_bs = mk_binding sym_i CF.Ctype.signed_int in
  let body_stmts =
    List.map
      mk_stmt
      [ lua_state_ss;
        AilSexpr
          (call
             "lua_createtable"
             [ mk_expr (AilEident sym_L); var_sym sym_size; int_const 0 ]);
        A.AilSdeclaration [ (sym_i, Some (int_const 0)) ];
        mk_push_array_loop
      ]
  in
  let block_bindings = [ lua_state_bs; i_bs ] in
  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in
  let struct_ptr_type =
    mk_ctype
      CF.Ctype.(Pointer (CF.Ctype.no_qualifiers, mk_ctype CF.Ctype.(Struct struct_tag)))
  in
  let struct_decl_type = (CF.Ctype.no_qualifiers, struct_ptr_type, false) in
  let size_decl_type = (CF.Ctype.no_qualifiers, CF.Ctype.signed_int, false) in
  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            ( false,
              (CF.Ctype.no_qualifiers, CF.Ctype.void),
              [ struct_decl_type; size_decl_type ],
              false,
              false,
              false )) ) )
  in
  let def = (id, (loc, 0, attrs, [ sym_arr; sym_size ], final_body)) in
  (decl, def)


let generate_c_fn_get_struct
      (struct_data :
        A.ail_identifier
        * (Cerb_location.t * CF.Annot.attributes * CF.Ctype.tag_definition))
  : CF.GenTypes.genTypeCategory A.statement * wrapper_function
  =
  (*
     struct lua_State* L = lua_get_state();
  intptr_t ptr = luaL_checkinteger(L, 1);
  struct s* data = (struct s*\) ptr;
  lua_cn_push_s(data);
  return 1;
  *)
  let struct_name, _ = struct_data in
  let struct_ptr_type =
    mk_ctype
      CF.Ctype.(Pointer (CF.Ctype.no_qualifiers, mk_ctype CF.Ctype.(Struct struct_name)))
  in
  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let fn_sym = Sym.fresh (get_type_prefix ^ Sym.pp_string struct_name) in
  let id = Sym.fresh (generate_c_fn_wrapper_name fn_sym) in
  let call name args = mk_expr (AilEcall (mk_expr (AilEident (Sym.fresh name)), args)) in
  let var_sym s = mk_expr (AilEident s) in
  let int_const i =
    mk_expr (A.AilEconst (ConstantInteger (IConstant (Z.of_int i, Decimal, None))))
  in
  let sym_L = Sym.fresh "L" in
  let sym_ptr = Sym.fresh "ptr" in
  let sym_data = Sym.fresh "data" in
  (* 1. Lua State *)
  let lua_state_bs, lua_state_ss = generate_c_get_lua_state in
  (* 2. Get pointer off Lua stack *)
  let ptr_stmt =
    A.AilSdeclaration
      [ ( sym_ptr,
          Some
            (mk_expr
               (AilEcall
                  ( mk_expr (AilEident (Sym.fresh "luaL_checkinteger")),
                    [ var_sym sym_L; int_const 1 ] ))) )
      ]
  in
  let intptr_ty = CF.Ctype.(Ctype ([], Basic (Integer (Signed Intptr_t)))) in
  let ptr_bs = mk_binding sym_ptr intptr_ty in
  (* 3. Cast pointer to struct *)
  let cast_stmt =
    A.AilSdeclaration
      [ ( sym_data,
          Some
            (mk_expr
               (AilEcast
                  (CF.Ctype.no_qualifiers, struct_ptr_type, mk_expr (AilEident sym_ptr))))
        )
      ]
  in
  let cast_bs = mk_binding sym_data struct_ptr_type in
  (* 4. Call lua_cn_push_<struct> to push struct as table onto stack *)
  let push_stmt =
    A.AilSexpr (call (generate_c_fn_push_struct_name struct_name) [ var_sym sym_data ])
  in
  (* 5. Return 1 to let Lua know how many values to pop off the stack *)
  let ret_stmt = A.AilSreturn (int_const 1) in
  let body_stmts =
    [ mk_stmt lua_state_ss;
      mk_stmt ptr_stmt;
      mk_stmt cast_stmt;
      mk_stmt push_stmt;
      mk_stmt ret_stmt
    ]
  in
  let block_bindings = [ lua_state_bs; ptr_bs; cast_bs ] in
  let final_body = mk_stmt (A.AilSblock (block_bindings, body_stmts)) in
  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            (false, (CF.Ctype.no_qualifiers, CF.Ctype.signed_int), [], false, false, false))
      ) )
  in
  let def = (id, (loc, 0, attrs, [], final_body)) in
  (*lua_cn_register_c_func("get_s", lua_cn_get_s);*)
  let register_struct_stmt =
    let register_fn_expr = mk_expr (A.AilEident (Sym.fresh "lua_cn_register_c_func")) in
    let fn_expr = mk_expr (A.AilEstr (None, [ (loc, [ Sym.pp_string fn_sym ]) ])) in
    let get_struct_expr = mk_expr (A.AilEident id) in
    mk_stmt
      (A.AilSexpr (mk_expr (A.AilEcall (register_fn_expr, [ fn_expr; get_struct_expr ]))))
  in
  (register_struct_stmt, (decl, def))


let generate_c_fn_push_metadata
      (globals_decl : A.sigma_declaration)
      (get_bind_stmts : CF.GenTypes.genTypeCategory A.statement list)
      (sizeof_decls : A.sigma_declaration list)
      (offset_decls : A.sigma_declaration list)
  : wrapper_function
  =
  let make_fn_call_stmt (x : A.sigma_declaration) = mk_stmt (make_fn_call x) in
  let globals_stmt = make_fn_call_stmt globals_decl in
  let gets_block_stmts = mk_stmt (A.AilSblock ([], get_bind_stmts)) in
  let sizeof_block_stmts =
    mk_stmt (A.AilSblock ([], List.map make_fn_call_stmt sizeof_decls))
  in
  let offset_block_stmts =
    mk_stmt (A.AilSblock ([], List.map make_fn_call_stmt offset_decls))
  in
  let body_stmts =
    [ globals_stmt; gets_block_stmts; sizeof_block_stmts; offset_block_stmts ]
  in
  let loc = Cerb_location.unknown in
  let attrs = CF.Annot.no_attributes in
  let id = Sym.fresh "lua_cn_push_runtime_metadata" in
  let decl =
    ( id,
      ( loc,
        attrs,
        A.(
          Decl_function
            (false, (CF.Ctype.no_qualifiers, CF.Ctype.void), [], false, false, false)) )
    )
  in
  let def = (id, (loc, 0, attrs, [], mk_stmt (A.AilSblock ([], body_stmts)))) in
  (decl, def)


let generate_lua_ctype_sizeof (ctype : CF.Ctype.ctype) : lua_expression =
  LuaS.Field (cn_sizeof_field_sym, generate_lua_ctype_symbol ctype)


let generate_lua_ctype_get (ctype : CF.Ctype.ctype) : lua_expression =
  let ctype_sym_expr = generate_lua_ctype_symbol ctype in
  match ctype_sym_expr with
  | LuaS.Call (array_prefix, array_args) ->
    LuaS.Call (Pp_lua.pp_expr cn_generate_get_field_prefix_sym ^ array_prefix, array_args)
  | _ ->
    LuaS.Symbol (Pp_lua.pp_expr cn_get_field_prefix_sym ^ Pp_lua.pp_expr ctype_sym_expr)


let generate_lua_filename output_dir basefile =
  let filename = Filename.remove_extension basefile ^ ".lua" in
  Filename.concat output_dir filename


let generate_lua_fn_prefix (c_fn_name : Sym.t) =
  Pp_lua.pp_expr cn_sym ^ "." ^ Sym.pp_string c_fn_name ^ "."


let generate_lua_lemma_fn_prefix (c_fn_name : Sym.t) =
  Pp_lua.pp_expr cn_lemma_sym ^ "." ^ Sym.pp_string c_fn_name ^ "."


let generate_lua_precondition_fn_name (c_fn_name : Sym.t) ?(is_lemma = false) () =
  let suffix = "precondition" in
  if is_lemma then
    generate_lua_lemma_fn_prefix c_fn_name ^ suffix
  else
    generate_lua_fn_prefix c_fn_name ^ suffix


let generate_lua_postcondition_fn_name (c_fn_name : Sym.t) ?(is_lemma = false) () =
  let suffix = "postcondition" in
  if is_lemma then
    generate_lua_lemma_fn_prefix c_fn_name ^ suffix
  else
    generate_lua_fn_prefix c_fn_name ^ suffix


let generate_lua_push_globals_fn_name = Pp_lua.pp_expr cn_sym ^ "." ^ "push_globals"

let generate_lua_push_frame_fn_name (c_fn_name : Sym.t) =
  generate_lua_fn_prefix c_fn_name ^ "push_frame"


let generate_lua_inline_fn_name (func_id : Sym.t) =
  Pp_lua.pp_expr (LuaS.Field (cn_inline_sym, LuaS.Symbol (Sym.pp_string func_id)))


let generate_c_fn_push_globals (globals : (Sym.t * CF.Ctype.ctype) list)
  : wrapper_function
  =
  let lua_fn_name = generate_lua_push_globals_fn_name in
  let c_wrapper_fn_name = generate_c_push_globals_fn_wrapper_name in
  let converted_globals = convert_c_args_to_wrapper_args globals in
  generate_c_fn_wrapper_def
    lua_fn_name
    c_wrapper_fn_name
    converted_globals
    ~global:true
    ()


let generate_lua_inline_fn
      (fn_name : string)
      (fn_args :
        (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list)
      (fn_body : lua_statements)
  =
  let args_exprs = List.map (fun (sym, _) -> LuaS.Symbol (Sym.pp_string sym)) fn_args in
  LuaS.FunctionDef (fn_name, args_exprs, fn_body, false)


let generate_lua_cn_inline_lemma_call (in_exec : lua_cn_exec) : lua_cn_exec =
  let exec, expr = pop_expr_from_exec in_exec in
  push_stmts_to_exec (exec, [ LuaS.SExpr (LuaS.Field (cn_lemma_sym, expr)) ])


let generate_lua_cn_lemma_fn
      ((fn_sym, fn_params) :
        CF.Ctype.union_tag * (CF.Ctype.union_tag * CF.Ctype.ctype) list)
  : lua_cn_exec
  =
  let args_expr = List.map (fun (sym, _) -> convert sym) fn_params in
  let push_fn = LuaS.FunctionCall (Pp_lua.pp_expr cn_frames_push_fn_sym, []) in
  let precond_fn_call =
    LuaS.FunctionCall
      (generate_lua_precondition_fn_name fn_sym ~is_lemma:true (), args_expr)
  in
  let postcond_fn_call =
    LuaS.FunctionCall
      (generate_lua_postcondition_fn_name fn_sym ~is_lemma:true (), args_expr)
  in
  let pop_fn = LuaS.FunctionCall (Pp_lua.pp_expr cn_frames_pop_fn_sym, []) in
  let fn_def =
    LuaS.FunctionDef
      ( Pp_lua.pp_expr (LuaS.Field (cn_lemma_sym, convert fn_sym)),
        args_expr,
        [ push_fn; precond_fn_call; postcond_fn_call; pop_fn ],
        true )
  in
  ([ fn_def ], [], get_empty_lua_expr)


let generate_lua_cn_get_or_put_ownership
      (spec_mode : lua_expression)
      (ptr : lua_expression)
      (sizeof : lua_expression)
      (loop_ownership : lua_expression)
  : lua_statement
  =
  LuaS.FunctionCall
    ( Pp_lua.pp_expr cn_get_or_put_ownership_sym,
      [ spec_mode; ptr; sizeof; loop_ownership ] )


let generate_lua_cn_const_number (number : Z.t) : lua_expression =
  let int_type_str = "i64" in
  LuaS.Number_Int (LuaS.Symbol (Z.to_string number), int_type_str)


let generate_lua_owned_fn_name = Pp_lua.pp_expr cn_owned_sym

let generate_lua_runtime_core_req (* local cn = require("lua_cn_runtime_core") *) =
  LuaS.LocalAssign
    ( get_expr_str cn_sym,
      Some (LuaS.Call ("require", [ LuaS.String "lua_cn_runtime_core" ])) )


let generate_lua_runtime_return (* return cn *) = LuaS.Return (Some cn_sym)

let generate_lua_env_req (* _ENV = cn.env *) = LuaS.Assign ("_ENV", Some cn_env_sym)

let generate_lua_c_number_locals : lua_statements =
  let generate_local_for_number_type num_type =
    [ LuaS.LocalAssign
        (num_type, Some (LuaS.Field (lua_c_number_library_sym, LuaS.Symbol num_type)));
      LuaS.LineBreak
    ]
  in
  let unsigned_locals =
    List.concat (List.map generate_local_for_number_type lua_c_number_unsigned_types)
  in
  let signed_locals =
    List.concat (List.map generate_local_for_number_type lua_c_number_signed_types)
  in
  unsigned_locals @ signed_locals @ [ LuaS.LineBreak ]


let generate_lua_cn_conditional (cases : (lua_expression option * lua_statements) list)
  : LuaS.stmt
  =
  LuaS.IfElse cases


let generate_lua_cn_local_assignment (var : string) (value : lua_expression option)
  : lua_statement
  =
  let fixed_var = fix_for_reserve_words_str var in
  LuaS.LocalAssign (fixed_var, value)


let generate_lua_cn_assignment (var : string) (value : lua_expression option)
  : lua_statement
  =
  let fixed_var = fix_for_reserve_words_str var in
  LuaS.Assign (fixed_var, value)


let generate_lua_cn_match_case_equality ((subject, case) : lua_expression * string)
  : lua_expression
  =
  let tag_sym = LuaS.Symbol "tag" in
  let subject_field = LuaS.Field (subject, tag_sym) in
  let case_str = LuaS.String case in
  LuaS.Binary (LuaS.Eq (subject_field, case_str, "incompatible"))


let generate_lua_cn_map_define_call (default_expr : lua_expression) =
  LuaS.Call (Pp_lua.pp_expr cn_map_def_sym, [ default_expr ])


let generate_lua_cn_spec_decl (fn_sym : CF.Ctype.union_tag) : lua_statement =
  let fn_name = Pp_lua.pp_expr cn_sym ^ "." ^ Sym.pp_string fn_sym in
  LuaS.Assign (fn_name, Some generate_lua_cn_empty_table)

let generate_lua_push_frame_fn
      (lua_fn_name : string)
      (c_fn_args :
        (CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) list)
  : LuaS.stmt
  =
  let get_args =
    List.map
      (fun (arg : CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool)) ->
         let c_sym, _ = arg in
         let c_sym_as_lua_expr = LuaS.Symbol (Sym.pp_string c_sym) in
         LuaS.Assign
           ( Pp_lua.pp_expr (LuaS.Field (cn_locals_sym, c_sym_as_lua_expr)),
             Some c_sym_as_lua_expr ))
      c_fn_args
  in
  let initial_push_fn =
    [ LuaS.FunctionCall (Pp_lua.pp_expr cn_frames_push_fn_sym, []) ]
  in
  let lua_fn_body = initial_push_fn @ get_args in
  let get_arg_name
        (arg : CF.Ctype.union_tag * (CF.Ctype.qualifiers * CF.Ctype.ctype * bool))
    =
    let c_sym, _ = arg in
    LuaS.Symbol (Sym.pp_string c_sym)
  in
  let lua_fn_args = List.map get_arg_name c_fn_args in
  LuaS.FunctionDef (lua_fn_name, lua_fn_args, lua_fn_body, false)


let generate_lua_cn_fn_push_globals (globals : (Sym.t * CF.Ctype.ctype) list) : LuaS.stmt =
  let lua_fn_name = generate_lua_push_globals_fn_name in
  let get_global_arg arg =
    let c_sym, _ = arg in
    convert c_sym
  in
  let lua_fn_args = List.map get_global_arg globals in
  let lua_fn_body =
    List.map
      (fun sym ->
         LuaS.Assign (Pp_lua.pp_expr (LuaS.Field (cn_globals_sym, sym)), Some sym))
      lua_fn_args
  in
  LuaS.FunctionDef (lua_fn_name, lua_fn_args, lua_fn_body, true)


let generate_lua_cn_error_stack_push (msg : string) =
  LuaS.FunctionCall (get_expr_str cn_error_stack_push_sym, [ LuaS.String msg ])


let generate_lua_cn_error_stack_pop =
  LuaS.FunctionCall (get_expr_str cn_error_stack_pop_sym, [])


let generate_lua_cn_assert
      (error_msg : string)
      (in_exec : lua_cn_exec)
      (spec_mode : CF.Ctype.union_tag)
  : lua_cn_exec
  =
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
    let spec_mode_field = LuaS.Symbol (Sym.pp_string spec_mode) in
    let core_stmt =
      LuaS.FunctionCall (Pp_lua.pp_expr cn_assert_sym, [ assert_expr; spec_mode_field ])
    in
    let stmts = [ push_err_stmt; core_stmt; pop_err_stmt ] in
    let (cn_exec_for_assert : lua_cn_exec) = push_stmts_to_exec (exec', stmts) in
    cn_exec_for_assert)
  else
    get_empty_lua_cn_exec


let generate_lua_cn_return (expr : lua_expression) (is_unit : bool) : LuaS.stmt =
  LuaS.Return (if is_unit then None else Some expr)


let generate_lua_cn_pname_resource_call
      (pname : CF.Ctype.union_tag)
      (args : lua_cn_exec list)
  : lua_cn_exec
  =
  let execs_and_exprs = List.map (fun x -> pop_expr_from_exec x) args in
  let execs, exprs = List.split execs_and_exprs in
  let final_expr = LuaS.Call (Sym.pp_string pname, exprs) in
  push_expr_to_exec (concat execs, final_expr)


let generate_lua_cn_number_limit_fn_name (limit_str : string) (integer_type_str : string)
  : string
  =
  let lua_expr_str =
    Pp_lua.pp_expr (LuaS.Number_IntLimit (limit_str, integer_type_str))
  in
  if String.ends_with ~suffix:"()" lua_expr_str then
    String.sub lua_expr_str 0 (String.length lua_expr_str - 2)
  else
    failwith "Expected a function call here. Something went wrong."


let generate_lua_cn_resource sym ctype in_exec is_local_res : lua_cn_exec =
  let exec, expr = pop_expr_from_exec in_exec in
  let stmt =
    match rm_ctype ctype with
    | CF.Ctype.Void -> LuaS.SExpr expr
    | _ ->
      let sym_str = Sym.pp_string sym in
      if is_local_res then
        generate_lua_cn_local_assignment sym_str (Some expr)
      else
        generate_lua_cn_assignment sym_str (Some expr)
  in
  push_stmts_to_exec (exec, [ stmt ])


let generate_lua_cn_conj_loop
      ~permission_only_bounds
      (loop_stmts : lua_statements)
      (if_expr : lua_expression)
      (while_expr : lua_expression)
      (incr_stmt : lua_statement)
  : lua_statement
  =
  let loop_body =
    if permission_only_bounds then
      (* Optimise Fulminate output if permission only consists of bounds *)
      loop_stmts @ [ incr_stmt ]
    else (
      let if_stmt =
        generate_lua_cn_conditional [ (Some if_expr, loop_stmts); (None, []) ]
      in
      [ if_stmt; incr_stmt ])
  in
  LuaS.While (while_expr, loop_body)


let generate_lua_cn_increment_stmt (sym : CF.Ctype.union_tag) (int_type : BT.t)
  : lua_statement
  =
  let sym_str = Sym.pp_string sym in
  let int_type_str = get_lua_c_int_type_str int_type in
  LuaS.Assign
    ( sym_str,
      Some (LuaS.Binary (LuaS.Add (LuaS.Symbol sym_str, LuaS.Symbol "1", int_type_str)))
    )


let generate_lua_cn_each_ownership_opt
      (spec_mode : lua_expression)
      (ptr : lua_expression)
      (range : lua_expression)
      (loop_ownership : lua_expression)
      (sizeof : lua_expression)
      (range_type : BT.t)
  : lua_statement
  =
  let sizeof_expr =
    LuaS.Binary (LuaS.Multiply (range, sizeof, get_lua_c_int_type_str range_type))
  in
  generate_lua_cn_get_or_put_ownership spec_mode ptr sizeof_expr loop_ownership


let generate_lua_cn_each_pname_call
      (pname : CF.Ctype.union_tag)
      (ptr : CF.Ctype.union_tag)
      (spec_mode : CF.Ctype.union_tag)
      (loop_ownership_opt : CF.Ctype.union_tag option)
      (args : lua_cn_exec list)
  : lua_cn_exec
  =
  let loop_ownership =
    match loop_ownership_opt with Some x -> convert x | None -> LuaS.Symbol "nil"
  in
  let execs, exprs =
    List.split
      (List.map
         (fun x ->
            let exec, expr = pop_expr_from_exec x in
            (exec, expr))
         args)
  in
  let pname_call_expr =
    LuaS.Call
      ( Sym.pp_string pname,
        [ convert ptr ] @ exprs @ [ convert spec_mode; loop_ownership ] )
  in
  push_expr_to_exec (concat execs, pname_call_expr)


let generate_lua_cn_datatype (cn_datatype : A.ail_identifier CF.Cn.cn_datatype)
  : lua_statement
  =
  let sym_str sym = CF.Pp_utils.to_plain_pretty_string (CF.Pp_symbol.pp_identifier sym) in
  let dt_name = Sym.pp_string cn_datatype.cn_dt_name in
  let dt_table_members =
    List.map
      (fun (sym, args) ->
         let tbl_member_name = Sym.pp_string sym in
         (*@saljuk NOTE: For some reason, args are in reverse order. Doing this here so that we match spec *)
         let args = List.rev args in
         let arg_names = List.map (fun (id, _) -> sym_str id) args in
         let tbl_member_fn_args = List.map (fun x -> LuaS.Symbol x) arg_names in
         let arg_tbl_fields =
           let gen_arg_fields =
             List.map (fun x -> LuaS.Named (x, LuaS.Symbol x)) arg_names
           in
           let tag_arg_field =
             LuaS.Named ("tag", LuaS.String (String.uppercase_ascii tbl_member_name))
           in
           [ tag_arg_field ] @ gen_arg_fields
         in
         let tbl_member_fn_body =
           LuaS.Return (Some (LuaS.Table (arg_tbl_fields, false)))
         in
         LuaS.Named
           ( tbl_member_name,
             LuaS.Function (tbl_member_fn_args, [ tbl_member_fn_body ], false) ))
      cn_datatype.cn_dt_cases
  in
  let dt_table = LuaS.Table (dt_table_members, true) in
  LuaS.LocalAssign (dt_name, Some dt_table)


let generate_lua_cn_function
      (fn_sym : CF.Ctype.union_tag)
      (fn_def : Definition.Function.t)
      (fn_exec : lua_cn_exec)
  =
  let params = List.map (fun (sym, _) -> LuaS.Symbol (Sym.pp_string sym)) fn_def.args in
  let stmts, _, _ = fn_exec in
  LuaS.LocalFunctionDef (Sym.pp_string fn_sym, params, stmts)


let generate_lua_cn_predicate
      (pred_sym : CF.Ctype.union_tag)
      (pred_def : Definition.Predicate.t)
      (pred_exec : lua_cn_exec)
  =
  let params =
    let initial =
      List.map
        (fun (sym, _) -> LuaS.Symbol (Sym.pp_string sym))
        ((pred_def.pointer, BT.(Loc ())) :: pred_def.iargs)
    in
    (* Every predicate gets a spec mode and loop ownership arg *)
    initial @ [ cn_spec_mode_var_sym; cn_loop_ownership_var_sym ]
  in
  let stmts, _, _ = pred_exec in
  LuaS.LocalFunctionDef (Sym.pp_string pred_sym, params, stmts)


let generate_lua_cn_bool_while_loop
      (sym : Sym.t)
      (bt : BT.t)
      (start_int_const : lua_expression)
      ((end_sym, end_int_const) : Sym.t * lua_expression)
      (while_cond : lua_expression)
      ?(if_cond_opt = None)
      ((stmts, _, expr) : lua_cn_exec)
  : lua_cn_exec
  =
  let b = convert (Sym.fresh_anon ()) in
  let b_decl =
    generate_lua_cn_local_assignment (Pp_lua.pp_expr b) (Some (LuaS.Bool true))
  in
  let incr_stmt = generate_lua_cn_increment_stmt sym bt in
  let start_stmt =
    generate_lua_cn_local_assignment (Sym.pp_string sym) (Some start_int_const)
  in
  let end_stmt =
    generate_lua_cn_local_assignment (Sym.pp_string end_sym) (Some end_int_const)
  in
  let bool_and_expr = LuaS.Binary (LuaS.And (b, expr)) in
  let bool_assign_stmt =
    generate_lua_cn_assignment (Pp_lua.pp_expr b) (Some bool_and_expr)
  in
  let loop_body =
    match if_cond_opt with
    | Some if_cond_expr ->
      let cases =
        [ (Some if_cond_expr, stmts @ [ bool_assign_stmt ]); (None, get_empty_lua_stmts) ]
      in
      let lua_if_stmt = generate_lua_cn_conditional cases in
      [ lua_if_stmt; incr_stmt ]
    | None -> [ bool_assign_stmt; incr_stmt ]
  in
  let while_loop = LuaS.While (while_cond, loop_body) in
  let block = LuaS.Block [ start_stmt; end_stmt; while_loop ] in
  ([ b_decl; block ], [], b)


let generate_lua_cn_struct_default
      (struct_sym : CF.Ctype.union_tag)
      (struct_members : (Id.t * CF.Ctype.ctype) list)
  : lua_statement
  =
  let sym_str sym = CF.Pp_utils.to_plain_pretty_string (CF.Pp_symbol.pp_identifier sym) in
  let default_struct_name = generate_lua_default_map_name struct_sym in
  let member_exprs =
    List.map
      (fun (id, ctype) ->
         let m_name = sym_str id in
         let default_value = generate_lua_ctype_default_value ctype in
         LuaS.Named (m_name, default_value))
      struct_members
  in
  let default_struct_table = LuaS.Table (member_exprs, true) in
  generate_lua_cn_local_assignment default_struct_name (Some default_struct_table)


(* ---------------------------------- *)
(*         Cn-to-Lua Terms            *)
(* ---------------------------------- *)

let cn_to_lua_const (constant : IT.const) (_baseType : BT.t) : lua_expression * bool =
  let default_int_type = "i32" in
  let z_sym z = LuaS.Symbol (Z.to_string z) in
  let lua_expression =
    match constant with
    | IT.Z z -> LuaS.Number_Int (z_sym z, default_int_type)
    | MemByte { alloc_id = _; value = i } -> LuaS.Number_Int (z_sym i, default_int_type)
    | Bits ((sgn, sz), i) ->
      let z_min, _ = BT.bits_range (sgn, sz) in
      let int_type_str =
        let sign_str = match sgn with BT.Signed -> "i" | BT.Unsigned -> "u" in
        let size_str = string_of_int sz in
        sign_str ^ size_str
      in
      let final_expr =
        if Z.equal i z_min && BT.equal_sign sgn BT.Signed then
          LuaS.Binary
            (LuaS.Subtract
               (z_sym (Z.neg (Z.sub (Z.neg i) Z.one)), z_sym Z.one, int_type_str))
        else
          LuaS.Number_Int (z_sym i, int_type_str)
      in
      final_expr
    | Q q -> LuaS.Number_Float q
    | Pointer { alloc_id = _; addr = a } ->
      let pointer_int_type = "i64" in
      LuaS.Number_Int (z_sym a, pointer_int_type)
    | Alloc_id _ -> failwith (__LOC__ ^ ": TODO Alloc_id")
    | Bool b -> LuaS.Bool b
    | Unit -> LuaS.Nil
    | Null -> LuaS.Symbol "0"
    | CType_const _ -> failwith (__LOC__ ^ ": TODO CType_const")
    | Default _bt -> failwith (__LOC__ ^ ": TODO Default_const")
  in
  let is_unit = constant == Unit in
  (lua_expression, is_unit)


let cn_to_lua_sym (c_sym : CF.Ctype.union_tag) ?(is_global = false) () : lua_expression =
  let fixed_sym = fix_for_reserve_words_sym c_sym in
  let lua_sym = convert fixed_sym in
  if is_global then
    LuaS.Field (cn_globals_sym, lua_sym)
  else
    lua_sym


let cn_to_lua_unop (expr, bt, unop) : lua_expression =
  let lua_c_int_type = get_lua_c_int_type_str bt in
  match unop with
  | IT.Not -> LuaS.Unary (LuaS.Not expr)
  | Negate -> LuaS.Unary (LuaS.Negate (expr, lua_c_int_type))
  | BW_FLS_NoSMT ->
    let failure_msg =
      Printf.sprintf
        ": FLS cannot be applied to index term of type %s"
        (Pp.plain (BT.pp bt))
    in
    (match bt with
     | Bits (Unsigned, n) ->
       if n == 64 then
         LuaS.Unary (LuaS.BW_FLSL expr)
       else if n == 32 then
         LuaS.Unary (LuaS.BW_FLS expr)
       else
         failwith (__LOC__ ^ failure_msg)
     | _ -> failwith (__LOC__ ^ failure_msg))
  | BW_Compl -> LuaS.Unary (LuaS.BW_Complement (expr, lua_c_int_type))
  | BW_CLZ_NoSMT | BW_CTZ_NoSMT | BW_FFS_NoSMT ->
    failwith (__LOC__ ^ ": Failure in trying to translate SMT-only unop from C source")


let cn_to_lua_offsetof (struct_tag : CF.Ctype.union_tag) (member_tag_str : string)
  : lua_expression
  =
  let struct_tag_str = Sym.pp_string struct_tag in
  LuaS.Field
    ( cn_offsets_field_sym,
      LuaS.Field (LuaS.Symbol struct_tag_str, LuaS.Symbol member_tag_str) )


let cn_to_lua_binop (expr_a, expr_b, bt_a, bt_b, binop) : lua_expression =
  let get_lua_c_int_type_str bt1 bt2 =
    match (bt1, bt2) with
    | BT.Loc (), BT.Integer | BT.Loc (), BT.Bits _ -> "i64"
    | BT.Integer, BT.Integer -> "i64"
    | _, BT.Bits (sign, size) | BT.Bits (sign, size), _ ->
      let sign_str = match sign with BT.Signed -> "i" | BT.Unsigned -> "u" in
      let size_str = string_of_int size in
      sign_str ^ size_str
    | _, _ -> "incompatible"
  in
  let lua_c_int_type = get_lua_c_int_type_str bt_a bt_b in
  let lua_expression =
    match binop with
    | IT.And -> LuaS.Binary (LuaS.And (expr_a, expr_b))
    | IT.Or -> LuaS.Binary (LuaS.Or (expr_a, expr_b))
    | Add -> LuaS.Binary (LuaS.Add (expr_a, expr_b, lua_c_int_type))
    | Sub -> LuaS.Binary (LuaS.Subtract (expr_a, expr_b, lua_c_int_type))
    | Mul | MulNoSMT -> LuaS.Binary (LuaS.Multiply (expr_a, expr_b, lua_c_int_type))
    | Div | DivNoSMT -> LuaS.Binary (LuaS.IntegerDivide (expr_a, expr_b, lua_c_int_type))
    | Exp | ExpNoSMT -> LuaS.Binary (LuaS.Exp (expr_a, expr_b, lua_c_int_type))
    | Rem | RemNoSMT -> LuaS.Binary (LuaS.Remainder (expr_a, expr_b, lua_c_int_type))
    | Mod | ModNoSMT -> LuaS.Binary (LuaS.Modulo (expr_a, expr_b, lua_c_int_type))
    | BW_Xor -> LuaS.Binary (LuaS.BW_Xor (expr_a, expr_b, lua_c_int_type))
    | BW_And -> LuaS.Binary (LuaS.BW_And (expr_a, expr_b, lua_c_int_type))
    | BW_Or -> LuaS.Binary (LuaS.BW_Or (expr_a, expr_b, lua_c_int_type))
    | ShiftLeft -> LuaS.Binary (LuaS.LeftShift (expr_a, expr_b, lua_c_int_type))
    | ShiftRight -> LuaS.Binary (LuaS.RightShift (expr_a, expr_b, lua_c_int_type))
    | LT -> LuaS.Binary (LuaS.LessThan (expr_a, expr_b, lua_c_int_type))
    | LTPointer -> LuaS.Binary (LuaS.LessThan (expr_a, expr_b, "i64"))
    | LE -> LuaS.Binary (LuaS.LessThanOrEqTo (expr_a, expr_b, lua_c_int_type))
    | LEPointer -> LuaS.Binary (LuaS.LessThanOrEqTo (expr_a, expr_b, "i64"))
    | Min -> LuaS.Binary (LuaS.Min (expr_a, expr_b, lua_c_int_type))
    | Max -> LuaS.Binary (LuaS.Max (expr_a, expr_b, lua_c_int_type))
    | EQ -> 
      LuaS.Binary (LuaS.Eq (expr_a, expr_b, lua_c_int_type))
    | Implies -> LuaS.Call ("implies", [ expr_a; expr_b ])
    | SetUnion -> failwith (__LOC__ ^ ": TODO SetUnion")
    | SetIntersection -> failwith (__LOC__ ^ ": TODO SetIntersection")
    | SetDifference -> failwith (__LOC__ ^ ": TODO SetDifference")
    | SetMember -> failwith (__LOC__ ^ ": TODO SetMember")
    | Subset -> failwith (__LOC__ ^ ": TODO Subset")
  in
  lua_expression


let cn_to_lua_struct_member (in_exec : lua_cn_exec) (member_term : Id.t) : lua_cn_exec =
  let exec, struct_expr = pop_expr_from_exec in_exec in
  let member_term_string =
    CF.Pp_utils.to_plain_pretty_string (CF.Pp_symbol.pp_identifier member_term)
  in
  let struct_member_expr = LuaS.Field (struct_expr, LuaS.Symbol member_term_string) in
  push_expr_to_exec (exec, struct_member_expr)


let cn_to_lua_struct_update
      (res_sym : CF.Ctype.union_tag)
      (member_term : Id.t)
      (m : Id.t)
      (expr1 : lua_expression)
      (expr2 : lua_expression)
  : lua_statement
  =
  let res_sym = LuaS.Symbol (Sym.pp_string res_sym) in
  let member_sym = LuaS.Symbol (Id.get_string member_term) in
  let lhs = LuaS.Field (res_sym, member_sym) in
  let rhs =
    if Id.equal member_term m then
      expr2
    else
      LuaS.Field (expr1, member_sym)
  in
  LuaS.Assign (Pp_lua.pp_expr lhs, Some rhs)


let cn_to_lua_ite
      (result_sym : CF.Ctype.union_tag)
      (l1 : lua_cn_exec)
      (l2 : lua_cn_exec)
      (l3 : lua_cn_exec)
  : lua_cn_exec
  =
  let result_str = Sym.pp_string result_sym in
  let lua_result_decl = generate_lua_cn_local_assignment result_str None in
  let lua_result_sym = LuaS.Symbol result_str in
  let l', if_expr = pop_expr_from_exec l1 in
  let if_stmts, _, _ = l2 in
  let else_stmts, _, _ = l3 in
  let cond_stmt =
    generate_lua_cn_conditional [ (Some if_expr, if_stmts); (None, else_stmts) ]
  in
  let l'' = push_stmts_to_exec (l', [ lua_result_decl; cond_stmt ]) in
  let l''' = push_expr_to_exec (l'', lua_result_sym) in
  l'''


let cn_to_lua_record_member (in_exec : lua_cn_exec) (member_term : Id.t) : lua_cn_exec =
  (*@saljuk NOTE: For now, record and struct members are exactly alike so we're reusing.
  Change if need be.
  *)
  cn_to_lua_struct_member in_exec member_term


let cn_to_lua_record (record_data : (Id.t * lua_cn_exec) list) : lua_cn_exec =
  let exec_and_table_data =
    List.map
      (fun (id, in_exec) ->
         let exec, expr = pop_expr_from_exec in_exec in
         let id_str =
           CF.Pp_utils.to_plain_pretty_string (CF.Pp_symbol.pp_identifier id)
         in
         (exec, LuaS.Named (id_str, expr)))
      record_data
  in
  let execs, table_datas = List.split exec_and_table_data in
  let table_expr = LuaS.Table (table_datas, false) in
  let (merged_execs : lua_cn_exec) = concat execs in
  push_expr_to_exec (merged_execs, table_expr)


let cn_to_lua_constructor
      (dt : CF.Ctype.union_tag)
      (sym : CF.Ctype.union_tag)
      (args : lua_expressions)
  : lua_expression
  =
  let ail_to_lua_sym sym = LuaS.Symbol (Sym.pp_string sym) in
  LuaS.Call (Pp_lua.pp_expr (LuaS.Field (ail_to_lua_sym dt, ail_to_lua_sym sym)), args)


let cn_to_lua_member_shift
      (struct_expr : lua_expression)
      (struct_tag : CF.Ctype.union_tag)
      (member_tag : CF.Ctype.union_tag)
  : lua_expression
  =
  let member_tag_str = Sym.pp_string member_tag in
  let offsets_field_expr = cn_to_lua_offsetof struct_tag member_tag_str in
  LuaS.Call (Pp_lua.pp_expr cn_member_shift_sym, [ struct_expr; offsets_field_expr ])


let cn_to_lua_array_shift
      (ptr_exec : lua_cn_exec)
      (offset_exec : lua_cn_exec)
      (ctype : CF.Ctype.ctype)
  : lua_cn_exec
  =
  let l1, ptr_expr = pop_expr_from_exec ptr_exec in
  let l2, offset_expr = pop_expr_from_exec offset_exec in
  let sizeof_expr = generate_lua_ctype_sizeof ctype in
  let array_shift_expr =
    LuaS.Call (Pp_lua.pp_expr cn_array_shift_sym, [ ptr_expr; offset_expr; sizeof_expr ])
  in
  push_expr_to_exec (concat [ l1; l2 ], array_shift_expr)


let cn_to_lua_good : lua_expression = LuaS.Bool true

let cn_to_lua_map_set
      (map : lua_expression)
      (key : lua_expression)
      (value : lua_expression)
  : lua_statement
  =
  LuaS.SExpr (LuaS.TableSet (map, key, value))


let cn_to_lua_map_get (map_exec : lua_cn_exec) (key_exec : lua_cn_exec) : lua_cn_exec =
  let l1, map_expr = pop_expr_from_exec map_exec in
  let l2, key_expr = pop_expr_from_exec key_exec in
  let map_get_expr = LuaS.TableGet (map_expr, key_expr) in
  let final_exec = push_expr_to_exec (concat [ l1; l2 ], map_get_expr) in
  final_exec


let cn_to_lua_apply sym in_execs : lua_cn_exec =
  let execs_and_exprs = List.map pop_expr_from_exec in_execs in
  let execs, exprs = List.split execs_and_exprs in
  let apply_expr = LuaS.Call (Sym.pp_string sym, exprs) in
  let merged_execs = concat execs in
  let final_exec = push_expr_to_exec (merged_execs, apply_expr) in
  final_exec


let cn_to_lua_let (var : CF.Ctype.union_tag) (val_expr : lua_expression) : lua_cn_exec =
  let stmt = generate_lua_cn_local_assignment (Sym.pp_string var) (Some val_expr) in
  ([ stmt ], [], get_empty_lua_expr)


let cn_to_lua_struct (res_sym : CF.Ctype.union_tag) (l : (Id.t * lua_cn_exec) list)
  : lua_cn_exec
  =
  let _, _, struct_expr = cn_to_lua_record l in
  let res_expr = LuaS.Symbol (Sym.pp_string res_sym) in
  let res_stmt =
    generate_lua_cn_local_assignment (Sym.pp_string res_sym) (Some struct_expr)
  in
  ([ res_stmt ], [], res_expr)


let cn_to_lua_cast (_from_type : BT.t) (to_type : BT.t) (cast_exec : lua_cn_exec)
  : lua_cn_exec
  =
  let int_type_str = get_lua_c_int_type_str to_type in
  if String.equal int_type_str "incompatible" then
    cast_exec
  else (
    let exec, expr = pop_expr_from_exec cast_exec in
    let int_expr = LuaS.Number_Int (expr, int_type_str) in
    push_expr_to_exec (exec, int_expr))
