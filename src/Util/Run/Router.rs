use std::collections::BTreeMap;
use std::rc::Rc;

type RouterHandler = purust_core::Func1<crate::UnknownType, Rc<Purs_Control_Monad_Free::Free>>;

#[derive(Clone, Default)]
pub struct RouterBuilder {
    handlers: BTreeMap<String, RouterHandler>,
}

pub fn Util_Run_Router_empty() -> Rc<RouterBuilder> {
    // Preserve the identity of the JS module's constant empty object. This
    // follows the generated runtime's thread-local module-value convention.
    thread_local! {
        static EMPTY: std::cell::OnceCell<Rc<RouterBuilder>> = const { std::cell::OnceCell::new() };
    }
    EMPTY.with(|empty| {
        empty
            .get_or_init(|| Rc::new(RouterBuilder::default()))
            .clone()
    })
}

pub fn Util_Run_Router__on(
    tag: String,
    handler: RouterHandler,
    builder: Rc<RouterBuilder>,
) -> Rc<RouterBuilder> {
    // Registration is persistent: other uses of the original builder retain
    // their handlers, and replacing a tag only changes the returned builder.
    let mut next = (*builder).clone();
    next.handlers.insert(tag, handler);
    Rc::new(next)
}

pub fn Util_Run_Router__build(
    builder: Rc<RouterBuilder>,
    fallback: RouterHandler,
    tag: String,
    payload: crate::UnknownType,
    original: crate::UnknownType,
) -> Rc<Purs_Control_Monad_Free::Free> {
    match builder.handlers.get(&tag) {
        Some(handler) => handler(payload),
        None => fallback(original),
    }
}
