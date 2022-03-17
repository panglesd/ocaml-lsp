open Import

val set_ocamlformat_hook :
  (Document.t -> (string, string) result Fiber.t) -> unit

val run : unit -> unit

module Version = Version
module Document = Document
module Uri = Uri
