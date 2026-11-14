pub fn Util_Html_Clean_Clean__untag(
    whitelist_all: bool,
    whitelist: crate::UnknownType,
    blacklist_all: bool,
    blacklist: crate::UnknownType,
    replace_with_space: bool,
    input: String,
) -> String {
    let whitelist = untag_names(whitelist);
    let blacklist = untag_names(blacklist);
    untag_html(whitelist_all, &whitelist, blacklist_all, &blacklist, replace_with_space, &input)
}

fn untag_names(values: crate::UnknownType) -> std::collections::HashSet<String> {
    values.unwrap_array().iter().map(|value| {
        // Only ASCII tag names can match. Decoding is needed for case folding
        // such as Kelvin sign -> k; invalid UTF-16 cannot fold to an ASCII name.
        purust_core::purust_string_to_utf8_lossy(&value.unwrap_string()).to_lowercase()
    }).collect()
}

fn untag_html(
    whitelist_all: bool,
    whitelist: &std::collections::HashSet<String>,
    blacklist_all: bool,
    blacklist: &std::collections::HashSet<String>,
    replace_with_space: bool,
    input: &str,
) -> String {
    // Exact scanner for /<\/?([a-zA-Z0-9:-]+)[^>]*>/g, not an HTML parser.
    // ASCII delimiters are also byte boundaries in purust's encoded UTF-16.
    // Unmatched text and kept matches stay byte-for-byte unchanged.
    let bytes = input.as_bytes();
    let mut result = String::with_capacity(input.len());
    let mut copied = 0;
    let mut search = 0;
    while let Some(offset) = input[search..].find('<') {
        let start = search + offset;
        let mut name_start = start + 1;
        if bytes.get(name_start) == Some(&b'/') { name_start += 1; }
        let mut name_end = name_start;
        while bytes.get(name_end).is_some_and(|b| b.is_ascii_alphanumeric() || *b == b':' || *b == b'-') {
            name_end += 1;
        }
        if name_start == name_end {
            search = start + 1;
            continue;
        }
        let Some(close) = input[name_end..].find('>') else { break; };
        let end = name_end + close + 1;
        let name = input[name_start..name_end].to_ascii_lowercase();
        result.push_str(&input[copied..start]);
        if (whitelist_all || whitelist.contains(&name)) && !(blacklist_all || blacklist.contains(&name)) {
            result.push_str(&input[start..end]);
        } else if replace_with_space {
            result.push(' ');
        }
        copied = end;
        search = end;
    }
    result.push_str(&input[copied..]);
    result
}
