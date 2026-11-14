pub fn Util_Type_Ulid__generateUlid() -> crate::UnknownType {
    purust_core::Value::Func1(purust_core::Func1::Static(|_| {
        purust_core::Value::String(purust_core::purust_string_from_utf8(
            &ulid::Ulid::generate().to_string().to_ascii_lowercase(),
        ))
    }))
}

pub fn Util_Type_Ulid__isValid(value: String) -> bool {
    // JS checks the original UTF-16 length, then Unicode uppercase and alphabet.
    // Uppercasing may expand a character (ß -> SS); it does not recheck length.
    // Validation is not a 128-bit decoder check: a leading Z is accepted too.
    purust_core::purust_string_to_utf16(&value).len() == 26
        && purust_core::purust_string_to_utf8_lossy(&value)
            .to_uppercase()
            .bytes()
            .all(|byte| b"0123456789ABCDEFGHJKMNPQRSTVWXYZ".contains(&byte))
}

#[cfg(test)]
mod ulid_tests {
    use super::*;

    #[test]
    fn validation_matches_js_alphabet_including_overflow_strings() {
        for value in [
            "00000000000000000000000000",
            "ZZZZZZZZZZZZZZZZZZZZZZZZZZ",
            "01arz3ndektsv4rrffq69g5fav",
            "01ARZ3NDEKTSV4RRFFQ69G5FAV",
        ] {
            assert!(Util_Type_Ulid__isValid(value.to_owned()));
        }
        for byte in 0_u8..=127 {
            let value = format!("{}{}", "0".repeat(25), char::from(byte));
            assert_eq!(
                Util_Type_Ulid__isValid(value),
                b"0123456789ABCDEFGHJKMNPQRSTVWXYZ".contains(&byte.to_ascii_uppercase())
            );
        }
        for value in [
            "",
            "0",
            "0000000000000000000000000",
            "000000000000000000000000000",
            "0000000000000000000000000é",
        ] {
            assert!(!Util_Type_Ulid__isValid(value.to_owned()));
        }
        for suffix in ["ß", "ſ", "ﬀ", "ﬅ", "ﬆ"] {
            let value = format!("{}{suffix}", "0".repeat(25));
            assert!(Util_Type_Ulid__isValid(
                purust_core::purust_string_from_utf8(&value)
            ));
        }
    }

    #[test]
    fn replaying_the_effect_generates_fresh_lowercase_ids() {
        let effect = Util_Type_Ulid__generateUlid();
        let mut ids = std::collections::HashSet::new();
        for _ in 0..1024 {
            let result = effect.unwrap_func1()(purust_core::Value::Unit);
            let id = result.unwrap_string();
            assert!(Util_Type_Ulid__isValid(id.clone()));
            assert_eq!(id, id.to_ascii_lowercase());
            assert!(ulid::Ulid::from_string(&id).is_ok());
            assert!(ids.insert(id));
        }
    }
}
