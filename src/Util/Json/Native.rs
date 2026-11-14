// JSON.parse without Yoga.JSON's BigInt reviver. The JavaScript try also covers
// the success callback; the failure callback runs outside it.
pub fn Util_Foreign_Native_parseJSONImpl(
    left: purust_core::Func1<String, std::rc::Rc<Purs_Data_Either::Either>>,
    right: purust_core::Func1<crate::UnknownType, std::rc::Rc<Purs_Data_Either::Either>>,
    input: String,
) -> std::rc::Rc<Purs_Data_Either::Either> {
    match Purs_Effect_Exception::purust_exception_try(|| {
        let parsed = Purs_Yoga_JSON::purust_json_parse_raw(input);
        crate::Value::Class(std::rc::Rc::new(right(parsed)))
    }) {
        Ok(result) => result
            .unwrap_class::<std::rc::Rc<Purs_Data_Either::Either>>()
            .clone(),
        Err(error) => left(Purs_Effect_Exception::Effect_Exception_showErrorImpl(error)),
    }
}
