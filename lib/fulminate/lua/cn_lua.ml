type cn_stmt  = Empty
type cn_stmts = cn_stmt list

let generate_lua_filename basefile 
  = (Filename.remove_extension basefile) ^ ".lua"