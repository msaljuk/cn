type runtime =
  | C
  | Lua

val set_runtime : runtime -> unit
val get_runtime : unit -> runtime
