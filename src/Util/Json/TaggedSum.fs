// Util.Json.TaggedSum: inject the missing `value` key (as the PureScript
// `undefined`) when an object carries a `type` tag without one, so the
// TaggedSum decoder can hand it to the inner Maybe decoder.

let fixTaggedSumRepMissingValue (foreignValue: obj) : obj =
    match foreignValue with
    | :? Map<string, obj> as fields ->
        if Map.containsKey "type" fields && not (Map.containsKey "value" fields) then
            box (Map.add "value" Foreign_FFI.psUndefined fields)
        else
            foreignValue
    | _ -> foreignValue
