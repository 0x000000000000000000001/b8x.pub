// HTML entity encoding/decoding matching the `he` library used by the JS
// backend: named entities for decoding, hexadecimal numeric references for
// encoding (unsafe symbols and non-ASCII code points, except newlines).

let private mustEncode (codePoint: int) : bool =
    codePoint = 0x22
    || codePoint = 0x26
    || codePoint = 0x27
    || codePoint = 0x3C
    || codePoint = 0x3E
    || codePoint = 0x60
    || codePoint >= 0x7F
    || (codePoint < 0x20 && codePoint <> 0x0A && codePoint <> 0x0D)

let private encodeEntities (str: string) : string =
    let sb = System.Text.StringBuilder(str.Length)
    let mutable index = 0
    while index < str.Length do
        let ch = str.[index]
        let codePoint, size =
            if System.Char.IsHighSurrogate(ch) && index + 1 < str.Length && System.Char.IsLowSurrogate(str.[index + 1]) then
                System.Char.ConvertToUtf32(ch, str.[index + 1]), 2
            else
                int ch, 1

        if mustEncode codePoint then
            sb.Append("&#x").Append(codePoint.ToString("X", System.Globalization.CultureInfo.InvariantCulture)).Append(";")
            |> ignore
        else
            sb.Append(str, index, size) |> ignore

        index <- index + size

    sb.ToString()

let _encodeHtmlEntities (value: obj) : obj =
    try box (encodeEntities (unbox<string> value))
    with _ -> value

let _decodeHtmlEntities (value: obj) : obj =
    try box (System.Net.WebUtility.HtmlDecode(unbox<string> value))
    with _ -> value
