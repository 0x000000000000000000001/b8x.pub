pub fn Util_Type_String_String_removeAccents(input: String) -> String {
    use purust_core::{purust_char_from_code_unit, purust_string_to_utf16};
    let mut result = String::with_capacity(input.len());
    let mut run = String::new();
    // Normalize valid scalar runs, retaining isolated UTF-16 units as barriers.
    for decoded in char::decode_utf16(purust_string_to_utf16(&input)) {
        match decoded {
            Ok(c) => run.push(c),
            Err(error) => {
                append_without_accents(&mut result, &run);
                run.clear();
                result.push(purust_char_from_code_unit(error.unpaired_surrogate()));
            }
        }
    }
    append_without_accents(&mut result, &run);
    result
}

fn append_without_accents(result: &mut String, run: &str) {
    use unicode_normalization::UnicodeNormalization;
    // JS removes only U+0300..U+036F after NFD, not all combining marks or NFKD.
    let normalized: String = run.nfd().filter(|c| !('\u{0300}'..='\u{036f}').contains(c)).collect();
    result.push_str(&purust_core::purust_string_from_utf8(&normalized));
}

pub fn Util_Type_String_String_upperCaseFirst(input: String) -> String {
    case_first(input, true)
}

pub fn Util_Type_String_String_lowerCaseFirst(input: String) -> String {
    case_first(input, false)
}

fn case_first(input: String, upper: bool) -> String {
    let Some(first) = input.chars().next() else { return input; };
    let unit = purust_core::purust_char_to_code_unit(first);
    // charAt(0) selects one code unit, even at the start of a surrogate pair.
    let Some(character) = char::from_u32(unit as u32) else { return input; };
    // Pin Unicode 16 with the JS reference instead of depending on rustc's tables.
    let mapping = if upper {
        unicode_case_mapping::to_uppercase(character)
    } else {
        let [first, second] = unicode_case_mapping::to_lowercase(character);
        [first, second, 0]
    };
    if mapping[0] == 0 { return input; }
    let mapped: String = mapping.into_iter().filter(|point| *point != 0)
        .map(|point| char::from_u32(point).expect("Unicode case mapping must contain scalars")).collect();
    let mut result = purust_core::purust_string_from_utf8(&mapped);
    result.push_str(&input[first.len_utf8()..]);
    result
}
