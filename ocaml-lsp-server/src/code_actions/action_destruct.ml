open Import
open Fiber.O

let action_kind = "destruct"

let kind = CodeActionKind.Other action_kind

let code_action_of_case_analysis doc uri (loc, newText) =
  let range : Range.t = Range.of_loc loc in
  let edit : WorkspaceEdit.t =
    let textedit : TextEdit.t = { range; newText } in
    let version = Document.version doc in
    let textDocument =
      OptionalVersionedTextDocumentIdentifier.create ~uri ~version ()
    in
    let edit =
      TextDocumentEdit.create ~textDocument ~edits:[ `TextEdit textedit ]
    in
    WorkspaceEdit.create ~documentChanges:[ `TextDocumentEdit edit ] ()
  in
  let title = String.capitalize_ascii action_kind in
  let command =
    Client.Vscode.Commands.Custom.next_hole ~start_position:range.start
      ~notify_if_no_hole:false ()
  in
  CodeAction.create ~title ~kind:(CodeActionKind.Other action_kind) ~edit
    ~command ~isPreferred:false ()

let code_action (state : State.t) doc (params : CodeActionParams.t) =
  let uri = params.textDocument.uri in
  match Document.kind doc with
  | Intf -> Fiber.return None
  | Impl -> (
    let command =
      let start = Position.logical params.range.start in
      let finish = Position.logical params.range.end_ in
      Query_protocol.Case_analysis (start, finish)
    in
    let* res = Document.dispatch doc command in
    match res with
    | Ok (loc, newText) -> (
      let+ formattedText =
        Ocamlformat_rpc.(format_type state.ocamlformat_rpc ~typ:newText)
      in
      match formattedText with
      | Ok formattedText -> Some (code_action_of_case_analysis doc uri (loc, formattedText))
      | Error _ -> Some (code_action_of_case_analysis doc uri (loc, newText)))
    | Error
        { exn =
            ( Merlin_analysis.Destruct.Wrong_parent _ | Query_commands.No_nodes
            | Merlin_analysis.Destruct.Not_allowed _
            | Merlin_analysis.Destruct.Useless_refine
            | Merlin_analysis.Destruct.Nothing_to_do )
        ; backtrace = _
        } ->
      Fiber.return None
    | Error exn -> Exn_with_backtrace.reraise exn)

let t state = { Code_action.kind; run = code_action state }
