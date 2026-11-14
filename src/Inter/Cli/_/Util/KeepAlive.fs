// Mirrors the JS `setInterval(() => {}, 10000)`: register a task that is never
// completed, so the entry point's event-loop wait blocks instead of letting
// the process exit.
let keepMainAlive = fun (_: obj) ->
    Sharpurs_Prelude.SharpursRuntime.EventLoopAdd(1)
    box null
