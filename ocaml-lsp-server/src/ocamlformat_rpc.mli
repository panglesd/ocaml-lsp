open Import

type t

val create : unit -> t

val stop : t -> unit Fiber.t

val format_type :
     t
  -> Document.t
  -> typ:string
  -> (string, [> `Msg of string | `No_process ]) result Fiber.t

val format_doc :
     ?options:(string * string) list
  -> t
  -> Document.t
  -> (TextEdit.t list, [> `Msg of string | `No_process ]) result Fiber.t

val run :
     logger:(type_:MessageType.t -> message:string -> unit Fiber.t)
  -> t
  -> (unit, [> `Disabled | `Binary_not_found ]) result Fiber.t
