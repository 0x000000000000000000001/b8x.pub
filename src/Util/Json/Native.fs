// JSON parsing for Util.Foreign.Native: `parseJSONImpl left right str` calls
// `right` with the parsed foreign value or `left` with the error message.
// Objects become Map<string, obj>, arrays become obj arrays and numbers are
// boxed doubles, matching the Sharpurs foreign representation.

let rec private nativeConvert (element: System.Text.Json.JsonElement) : obj =
    match element.ValueKind with
    | System.Text.Json.JsonValueKind.Object ->
        let fields = System.Collections.Generic.Dictionary<string, obj>()
        for property in element.EnumerateObject() do
            fields.[property.Name] <- nativeConvert property.Value
        box (Map.ofSeq (fields |> Seq.map (fun pair -> pair.Key, pair.Value)))
    | System.Text.Json.JsonValueKind.Array ->
        box (element.EnumerateArray() |> Seq.map nativeConvert |> Seq.toArray)
    | System.Text.Json.JsonValueKind.String -> box (element.GetString())
    | System.Text.Json.JsonValueKind.Number -> box (element.GetDouble())
    | System.Text.Json.JsonValueKind.True -> box true
    | System.Text.Json.JsonValueKind.False -> box false
    | _ -> box null

let parseJSONImpl (left: obj) (right: obj) (str: obj) : obj =
    try
        use document = System.Text.Json.JsonDocument.Parse(unbox<string> str)
        sharpurs_apply right (nativeConvert document.RootElement)
    with ex ->
        sharpurs_apply left (box (ex.ToString()))
