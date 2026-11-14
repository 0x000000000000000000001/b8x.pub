// Util.Signal FFI. The Sharpurs runtime keeps the process alive through the
// event-loop wait; .NET's default signal handling terminates the process, so
// registering a PureScript handler is a no-op.

let onSignalImpl (name: obj) (handler: obj) : obj =
    box null
