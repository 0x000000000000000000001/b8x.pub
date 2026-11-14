pub fn Util_Json_TaggedSum_fixTaggedSumRepMissingValue(value: crate::UnknownType) -> crate::UnknownType {
    // Only records with a string tag and no value property are widened.
    // An existing null/undefined property must remain present and unchanged.
    if let purust_core::Value::Class(native) = value.resolve() {
        if let Some(object) = native.downcast_ref::<std::rc::Rc<purust_core::SharedRecord>>() {
            if object.get("type").is_some_and(|tag| matches!(tag.resolve(), purust_core::Value::String(_)))
                && object.get("value").is_none()
            {
                let next = object.snapshot();
                next.insert("value".into(), purust_core::Value::Unit);
                return purust_core::Value::Class(std::rc::Rc::new(std::rc::Rc::new(next)));
            }
        }
        return value;
    }
    if let Some(fields) = value.__purust_record_fields() {
        if matches!(fields.get("type").map(|tag| tag.resolve()), Some(purust_core::Value::String(_)))
            && fields.get("value").is_none()
        {
            return value.__purust_set_field("value", purust_core::Value::Unit);
        }
    }
    value
}
