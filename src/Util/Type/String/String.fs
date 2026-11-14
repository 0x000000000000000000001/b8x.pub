// String helpers from Util.Type.String.String.

// Mirrors `str.normalize("NFD").replace(/[\u0300-\u036f]/g, "")`.
let removeAccents (value: obj) : obj =
    let str = unbox<string> value
    let decomposed = str.Normalize(System.Text.NormalizationForm.FormD)
    let sb = System.Text.StringBuilder(decomposed.Length)
    for ch in decomposed do
        let code = int ch
        if code < 0x0300 || code > 0x036F then
            sb.Append(ch) |> ignore
    box (sb.ToString())

let upperCaseFirst (value: obj) : obj =
    let str = unbox<string> value
    if System.String.IsNullOrEmpty(str) then box str
    else box (string (System.Char.ToUpperInvariant str.[0]) + str.Substring(1))

let lowerCaseFirst (value: obj) : obj =
    let str = unbox<string> value
    if System.String.IsNullOrEmpty(str) then box str
    else box (string (System.Char.ToLowerInvariant str.[0]) + str.Substring(1))
