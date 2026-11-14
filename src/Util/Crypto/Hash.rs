use std::rc::Rc;

pub fn Util_Crypto_Hash__xxhash64(input: String) -> crate::UnknownType {
    crate::Value::Func2(purust_core::Func2::Shared(Rc::new(move |_on_error: crate::Value, on_success: crate::Value| {
        // xxhash-wasm uses TextEncoder: isolated UTF-16 surrogates become U+FFFD.
        let utf8 = purust_core::purust_string_to_utf8_lossy(&input);
        let digest = xxhash_rust::xxh64::xxh64(utf8.as_bytes(), 0);
        on_success.unwrap_func1()(crate::Value::String(format!("{digest:x}")));
        crate::Value::Func3(purust_core::Func3::Shared(Rc::new(
            |_reason: crate::Value, _on_canceler_error: crate::Value, on_canceler_success: crate::Value| {
                on_canceler_success.unwrap_func1()(crate::Value::Unit)
            },
        )))
    })))
}
