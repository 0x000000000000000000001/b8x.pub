// Infra.RateLimit.Postgres.RateLimit FFI: the rate-limiter-flexible Postgres
// store semantics (upsert a counter row and reject when the duration's points
// are exceeded).

let private rateLimitUpsertSql =
    """
    INSERT INTO rate_limit VALUES ($1, $2, $3)
    ON CONFLICT(key) DO UPDATE SET
      points = CASE WHEN (rate_limit.expire <= $4) THEN $2 ELSE rate_limit.points + ($2) END,
      expire = CASE WHEN (rate_limit.expire <= $4) THEN $3 ELSE rate_limit.expire END
    RETURNING points, expire;
    """

let private rateLimitConsumed (row: obj) : float =
    match row with
    | :? Map<string, obj> as fields ->
        (match Map.tryFind "points" fields with
         | Some value ->
             (match value with
              | :? float as number -> number
              | :? int as number -> float number
              | :? int64 as number -> float number
              | _ -> 0.0)
         | None -> 0.0)
    | _ -> 0.0

let _consume (handle: obj) (key: obj) (points: obj) (durationSec: obj) : obj =
    box (fun (_: obj) ->
        box (
            System.Threading.Tasks.Task.Run(fun () ->
                let maxPoints =
                    match points with
                    | :? int as number -> number
                    | :? float as number -> int number
                    | _ -> 0

                let durationMs = int64 (unbox<int> durationSec) * 1000L
                let now = System.DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()

                let parameters =
                    box
                        [| box (unbox<string> key)
                           box 1
                           box (now + durationMs)
                           box now |]

                let rows = unbox<obj[]> (Infra_Client_Postgres_Postgres_FFI.pgRunQuery handle rateLimitUpsertSql parameters)
                let consumed = if rows.Length > 0 then rateLimitConsumed rows.[0] else 0.0
                box (consumed <= float maxPoints))
        ))
