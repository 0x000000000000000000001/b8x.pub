// Util.Run.Router FFI: a builder is a Map from variant tags to handlers.
// PureScript supplies the tag, payload, and original fallback value.

let empty : obj = box Map.empty<string, obj>

let _on (tag: obj) (handler: obj) (builder: obj) : obj =
    box (Map.add (unbox<string> tag) handler (unbox<Map<string, obj>> builder))

let _build (builder: obj) (fallback: obj) (tag: obj) (payload: obj) (original: obj) : obj =
    let handlers = unbox<Map<string, obj>> builder

    match Map.tryFind (unbox<string> tag) handlers with
    | Some handler -> sharpurs_apply handler payload
    | None -> sharpurs_apply fallback original
