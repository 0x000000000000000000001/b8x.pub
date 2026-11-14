pub fn Util_NeedOpt_jsonNull() -> crate::UnknownType {
    purust_core::Value::Null
}

pub fn Util_NeedOpt_isNull(value: crate::UnknownType) -> bool {
    matches!(value.resolve(), purust_core::Value::Null)
}
