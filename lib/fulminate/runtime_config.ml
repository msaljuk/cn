type runtime =
  | C
  | Lua

(*
  @note saljuk: I can't think of a clean way to make this align with the
  user's choice of runtime without making it a ref. I'm still hiding it in this
  module and using a one-time write pattern (see set_runtime below) 
  to allow a consistent view of the runtime across Fulminate. Open to ideas...
*)
let runtime: runtime option ref = ref None

let runtime_to_string = function
  | C -> "C"
  | Lua -> "Lua"

let set_runtime r =
  match !runtime with
  | None -> runtime := Some r
  | Some curr ->
      failwith 
      ("Cannot set runtime to " ^ (runtime_to_string r) ^ ". 
        It has already been initialized to " ^ (runtime_to_string curr))

let get_runtime () =
  match !runtime with
  | Some r -> r
  | None -> failwith "No valid runtime set."
  