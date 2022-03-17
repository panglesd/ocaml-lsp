(** Generic formatting facility for OCaml and Reason sources.

    Relies on [ocamlformat] for OCaml and [refmt] for reason *)

open Import

type error =
  | Unsupported_syntax of Document.Syntax.t
  | Missing_binary of { binary : string }
  | Unexpected_result of { message : string }
  | Unknown_extension of Uri.t
  | Hook_error of string * error

val message : error -> string

val set_hook : (Document.t -> (string, string) result Fiber.t) -> unit

val run : Document.t -> (TextEdit.t list, error) result Fiber.t
