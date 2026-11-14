// Util.Html.Clean.Clean._untag: strips every tag except those allowed by the
// whitelist/blacklist pair, mirroring the JavaScript implementation.

let private tagPattern = System.Text.RegularExpressions.Regex("</?([a-zA-Z0-9:-]+)[^>]*>")

let private lowerTagSet (tags: obj) : System.Collections.Generic.HashSet<string> =
    match tags with
    | :? System.Array as values ->
        System.Collections.Generic.HashSet<string>(
            values
            |> Seq.cast<obj>
            |> Seq.map (fun tag -> (unbox<string> tag).ToLowerInvariant())
        )
    | _ -> System.Collections.Generic.HashSet<string>()

let _untag (isWhitelistAll: obj) (whitelistTags: obj) (isBlacklistAll: obj) (blacklistTags: obj) (replaceWithSpace: obj) (input: obj) : obj =
    let whitelistAll = unbox<bool> isWhitelistAll
    let blacklistAll = unbox<bool> isBlacklistAll
    let whitelist = lowerTagSet whitelistTags
    let blacklist = lowerTagSet blacklistTags
    let replacement = if unbox<bool> replaceWithSpace then " " else ""

    let replace (match': System.Text.RegularExpressions.Match) =
        let tag = match'.Groups.[1].Value.ToLowerInvariant()
        let allowed = (whitelistAll || whitelist.Contains tag) && not (blacklistAll || blacklist.Contains tag)
        if allowed then match'.Value else replacement

    box (tagPattern.Replace(unbox<string> input, System.Text.RegularExpressions.MatchEvaluator(replace)))
