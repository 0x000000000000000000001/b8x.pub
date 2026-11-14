// Infra.Projection.Projector FFI: acquires a dedicated PostgreSQL session
// advisory lock so only one process projects a given schema at a time. The
// connection is intentionally kept open while the lock is held.

open Npgsql

let private projectorLockGuard = obj ()
let private projectorLocks = System.Collections.Generic.HashSet<string>()

let private projectorLockKey (host: string) (port: string) (database: string) (user: string) (lockName: string) : string =
    System.Text.Encoding.UTF8.GetBytes(
        "{\"host\":\"" + host
        + "\",\"port\":\"" + port
        + "\",\"database\":\"" + database
        + "\",\"user\":\"" + user
        + "\",\"lockName\":\"" + lockName
        + "\"}"
    )
    |> System.Convert.ToBase64String

let private tryAdvisoryLock (host: obj) (port: obj) (database: obj) (user: obj) (password: obj) (lockName: obj) : obj =
    box (fun (_: obj) ->
        box (
            System.Threading.Tasks.Task.Run(fun () ->
                let hostStr = unbox<string> host
                let portStr = unbox<string> port
                let databaseStr = unbox<string> database
                let userStr = unbox<string> user
                let passwordStr = unbox<string> password
                let lockNameStr = unbox<string> lockName
                let key = projectorLockKey hostStr portStr databaseStr userStr lockNameStr

                lock projectorLockGuard (fun () ->
                    if projectorLocks.Contains key then
                        box false
                    else
                        try
                            let connectionString =
                                sprintf
                                    "Host=%s;Port=%s;Database=%s;Username=%s;Password=%s;Keepalive=30"
                                    hostStr
                                    portStr
                                    databaseStr
                                    userStr
                                    passwordStr

                            let connection = new NpgsqlConnection(connectionString)
                            connection.Open()

                            use command = new NpgsqlCommand("SELECT pg_try_advisory_lock(hashtext($1)) as locked", connection)
                            let parameter = NpgsqlParameter()
                            parameter.DataTypeName <- "unknown"
                            parameter.Value <- box ("proj:" + lockNameStr)
                            command.Parameters.Add(parameter) |> ignore

                            use reader = command.ExecuteReader()
                            let locked = reader.Read() && unbox<bool> (reader.GetValue(0))

                            if locked then
                                projectorLocks.Add key |> ignore
                                box true
                            else
                                connection.Dispose()
                                box false
                        with _ ->
                            box false)
            )
        ))

let _tryAdvisoryLock (host: obj) (port: obj) (database: obj) (user: obj) (password: obj) (lockName: obj) : obj =
    box (fun (onError: obj) -> box (fun (onSuccess: obj) ->
        let effect = tryAdvisoryLock host port database user password lockName
        let pending = unbox<System.Threading.Tasks.Task<obj>> (sharpurs_apply effect null)
        pending.ContinueWith(fun (completed: System.Threading.Tasks.Task<obj>) ->
            if completed.IsFaulted then
                sharpurs_apply onError (box (completed.Exception.GetBaseException().Message)) |> ignore
            else
                sharpurs_apply onSuccess completed.Result |> ignore
        ) |> ignore
        box (fun (_reason: obj) -> box (fun (_onError: obj) -> box (fun (onSuccess: obj) ->
            sharpurs_apply onSuccess null
        )))
    ))
