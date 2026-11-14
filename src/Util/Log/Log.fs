// Writes straight to stdout without a trailing newline, like `process.stdout.write`.

let _write (value: obj) : obj =
    box (fun (_: obj) ->
        System.Console.Out.Write(unbox<string> value)
        System.Console.Out.Flush()
        box null)
