// Core.Mod.Time.Instant FFI: ISO formatting/parsing and Europe/Paris
// conversions mirroring the JavaScript `Date`/`Intl` implementation.

let private parisTimeZone () : System.TimeZoneInfo =
    try System.TimeZoneInfo.FindSystemTimeZoneById("Europe/Paris")
    with _ -> System.TimeZoneInfo.Utc

let private instantMs (value: obj) : int64 =
    match value with
    | :? float as number -> int64 number
    | :? int as number -> int64 number
    | :? int64 as number -> number
    | :? decimal as number -> int64 number
    | :? string as text ->
        (match System.Double.TryParse(text, System.Globalization.NumberStyles.Float, System.Globalization.CultureInfo.InvariantCulture) with
         | true, parsed -> int64 parsed
         | _ -> 0L)
    | _ -> 0L

let private formatIso (ms: int64) : string =
    System.DateTimeOffset.FromUnixTimeMilliseconds(ms).UtcDateTime.ToString("yyyy-MM-ddTHH:mm:ss.fffZ", System.Globalization.CultureInfo.InvariantCulture)

let private parisMonthName (month: int) : string =
    match month with
    | 1 -> "janvier"
    | 2 -> "février"
    | 3 -> "mars"
    | 4 -> "avril"
    | 5 -> "mai"
    | 6 -> "juin"
    | 7 -> "juillet"
    | 8 -> "août"
    | 9 -> "septembre"
    | 10 -> "octobre"
    | 11 -> "novembre"
    | _ -> "décembre"

let _toIsoString (value: obj) : obj =
    box (formatIso (instantMs value))

let _toHumanParisDate (value: obj) : obj =
    let paris = System.TimeZoneInfo.ConvertTimeFromUtc(System.DateTimeOffset.FromUnixTimeMilliseconds(instantMs value).UtcDateTime, parisTimeZone ())
    let day = paris.Day
    let month = parisMonthName paris.Month
    let year = paris.Year
    let hour = paris.Hour
    let minute = paris.Minute
    box (sprintf "%d %s %d à %02d:%02d" day month year hour minute)

let _toSendyScheduleDate (value: obj) : obj =
    let paris = System.TimeZoneInfo.ConvertTimeFromUtc(System.DateTimeOffset.FromUnixTimeMilliseconds(instantMs value).UtcDateTime, parisTimeZone ())
    box (paris.ToString("yyyy-MM-dd HH:mm:ss", System.Globalization.CultureInfo.InvariantCulture))

let _parseIsoString (just: obj) (nothing: obj) (input: obj) : obj =
    let text = unbox<string> input
    let mutable parsed = System.DateTimeOffset.MinValue
    let parsedOk =
        System.DateTimeOffset.TryParse(
            text,
            System.Globalization.CultureInfo.InvariantCulture,
            System.Globalization.DateTimeStyles.AssumeUniversal,
            &parsed
        )

    if parsedOk then
        sharpurs_apply just (box (float (parsed.ToUnixTimeMilliseconds())))
    else
        nothing

let _parseParisTime (just: obj) (nothing: obj) (year: obj) (month: obj) (day: obj) (hour: obj) (minute: obj) : obj =
    try
        let local = System.DateTime(int (unbox<int> year), int (unbox<int> month), int (unbox<int> day), int (unbox<int> hour), int (unbox<int> minute), 0, System.DateTimeKind.Unspecified)
        let utc = System.TimeZoneInfo.ConvertTimeToUtc(local, parisTimeZone ())
        sharpurs_apply just (box (formatIso (System.DateTimeOffset(utc, System.TimeSpan.Zero).ToUnixTimeMilliseconds())))
    with _ ->
        nothing
