// Infra.Client.Postgres.Postgres FFI backed by Npgsql.
//
// Parameters are sent with the `unknown` type name so PostgreSQL infers their
// type from the query context and the explicit casts, exactly like the
// node-postgres driver: values are serialized to their PostgreSQL text form
// (arrays become array literals, objects become JSON).
//
// Rows are returned as Map<string, obj>; numbers are boxed doubles because
// Foreign.tagOf only recognizes `double` as the "Number" tag.

open System.Threading.Tasks
open Npgsql

type PgPool(connectionString: string) =
    let dataSource = NpgsqlDataSource.Create(connectionString)
    member _.ConnectionString = connectionString
    member _.DataSource = dataSource

type PgConnection(connection: NpgsqlConnection) =
    member _.Connection = connection

let private pgString (value: obj) : string =
    match value with
    | null -> ""
    | :? string as text -> text
    | _ -> value.ToString()

let private pgInt (value: obj) : int =
    match value with
    | :? int as number -> number
    | :? float as number -> int number
    | :? int64 as number -> int number
    | :? string as text ->
        (match System.Int32.TryParse(text) with
         | true, parsed -> parsed
         | _ -> 0)
    | _ -> 0

let private pgDouble (value: obj) : float =
    match value with
    | :? float as number -> number
    | :? int as number -> float number
    | :? int64 as number -> float number
    | _ -> 0.0

// MARK: values -> PostgreSQL literals

let rec private pgLiteral (value: obj) : obj =
    match value with
    | null -> null
    | _ when System.Object.ReferenceEquals(value, Foreign_FFI.psUndefined) -> null
    | :? string as text -> box text
    | :? bool as flag -> box (if flag then "true" else "false")
    | :? float as number -> box (number.ToString("R", System.Globalization.CultureInfo.InvariantCulture))
    | :? int as number -> box (number.ToString(System.Globalization.CultureInfo.InvariantCulture))
    | :? int64 as number -> box (number.ToString(System.Globalization.CultureInfo.InvariantCulture))
    | :? System.Numerics.BigInteger as number -> box (number.ToString(System.Globalization.CultureInfo.InvariantCulture))
    | :? System.Array as items -> box (pgArrayLiteral items)
    | :? Map<string, obj> as fields -> box (pgJsonText (box fields))
    | _ -> box (value.ToString())

and private pgArrayLiteral (items: System.Array) : string =
    let encodeElement (element: obj) =
        let literal = pgLiteral element
        if isNull literal then "NULL"
        else
            let text = unbox<string> literal
            "\"" + text.Replace("\\", "\\\\").Replace("\"", "\\\"") + "\""

    "{"
    + System.String.Join(",", items |> Seq.cast<obj> |> Seq.map encodeElement)
    + "}"

and private pgJsonText (value: obj) : string =
    unbox<string> (sharpurs_apply Yoga_JSON__unsafeStringify value)

// MARK: rows -> foreign values

let rec private pgConvert (value: obj) : obj =
    match value with
    | null -> box null
    | :? System.DBNull -> box null
    | :? string as text -> box text
    | :? bool as flag -> box flag
    | :? int as number -> box (float number)
    | :? int64 as number -> box (float number)
    | :? int16 as number -> box (float number)
    | :? float as number -> box number
    | :? single as number -> box (float number)
    | :? decimal as number -> box (float number)
    | :? System.DateTime as timestamp -> box timestamp
    | :? System.Guid as guid -> box (guid.ToString())
    | :? System.Array as items -> box (items |> Seq.cast<obj> |> Seq.map pgConvert |> Seq.toArray)
    | _ -> box (value.ToString())

let private pgRow (reader: System.Data.Common.DbDataReader) : obj =
    let mutable fields = Map.empty
    for i in 0 .. reader.FieldCount - 1 do
        fields <- Map.add (reader.GetName i) (pgConvert (reader.GetValue i)) fields
    box fields

// MARK: execution

let private pgAddParameters (command: NpgsqlCommand) (parameters: obj) : unit =
    match parameters with
    | :? System.Array as items ->
        for index in 0 .. items.Length - 1 do
            let parameter = NpgsqlParameter()
            parameter.DataTypeName <- "unknown"
            let literal = pgLiteral (items.GetValue index)
            parameter.Value <- (if isNull literal then box System.DBNull.Value else literal)
            command.Parameters.Add(parameter) |> ignore
    | _ -> ()

let private pgExecuteOn (connection: NpgsqlConnection) (sql: string) (parameters: obj) (readRows: bool) : obj =
    use command = new NpgsqlCommand(sql, connection)
    pgAddParameters command parameters

    if readRows then
        use reader = command.ExecuteReader()
        let rows = ResizeArray<obj>()
        while reader.Read() do
            rows.Add(pgRow reader)
        box (rows.ToArray())
    else
        let affected = command.ExecuteNonQuery()
        box affected

let pgRunQuery (handle: obj) (sql: string) (parameters: obj) : obj =
    match handle with
    | :? PgConnection as dedicated -> pgExecuteOn dedicated.Connection sql parameters true
    | :? PgPool as pool ->
        use connection = pool.DataSource.OpenConnection()
        pgExecuteOn connection sql parameters true
    | _ -> failwith "Postgres: unknown handle"

let pgRunCount (handle: obj) (sql: string) (parameters: obj) : int =
    match handle with
    | :? PgConnection as dedicated -> unbox<int> (pgExecuteOn dedicated.Connection sql parameters false)
    | :? PgPool as pool ->
        use connection = pool.DataSource.OpenConnection()
        unbox<int> (pgExecuteOn connection sql parameters false)
    | _ -> failwith "Postgres: unknown handle"

let private pgTask (work: unit -> obj) : obj =
    box (fun (onError: obj) -> box (fun (onSuccess: obj) ->
        Task.Run(fun () ->
            let result = try Ok (work ()) with error -> Error error
            match result with
            | Ok value -> sharpurs_apply onSuccess value |> ignore
            | Error error -> sharpurs_apply onError (box error.Message) |> ignore
        ) |> ignore
        box (fun (_reason: obj) -> box (fun (_onError: obj) -> box (fun (onSuccess: obj) ->
            sharpurs_apply onSuccess null
        )))
    ))

// MARK: foreign exports

let _createConnectionPoolHandle (host: obj) (port: obj) (database: obj) (user: obj) (password: obj) (idleTimeoutMs: obj) : obj =
    let connectionString =
        sprintf
            "Host=%s;Port=%d;Database=%s;Username=%s;Password=%s;Maximum Pool Size=100;Timeout=30;Command Timeout=300;Include Error Detail=true"
            (pgString host)
            (pgInt port)
            (pgString database)
            (pgString user)
            (pgString password)

    box (fun (_: obj) -> box (PgPool(connectionString)))

let _closeHandle (handle: obj) : obj =
    pgTask (fun () ->
            match handle with
            | :? PgPool as pool -> pool.DataSource.Dispose()
            | :? PgConnection as dedicated -> dedicated.Connection.Dispose()
            | _ -> ()
            box null)

let _query (_encodeJson: obj) (handle: obj) (sql: obj) (parameters: obj) : obj =
    pgTask (fun () -> pgRunQuery handle (pgString sql) parameters)

let _queryCount (_encodeJson: obj) (handle: obj) (sql: obj) (parameters: obj) : obj =
    pgTask (fun () -> box (pgRunCount handle (pgString sql) parameters))

let _escapeIdentifier (identifier: obj) : obj =
    box ("\"" + (pgString identifier).Replace("\"", "\"\"") + "\"")

let _dedicate (handle: obj) : obj =
    pgTask (fun () ->
            match handle with
            | :? PgPool as pool ->
                let connection = new NpgsqlConnection(pool.ConnectionString)
                connection.Open()
                box (PgConnection connection)
            | _ -> failwith "Postgres: cannot dedicate a non-pool handle")

let _release (handle: obj) : obj =
    pgTask (fun () ->
            match handle with
            | :? PgConnection as dedicated -> dedicated.Connection.Dispose()
            | _ -> ()
            box null)
