module Infra.EventStore.Postgres.EventStore
  ( appendEvents
  , buildJsonPath
  , buildWhere
  , interpretEventStore
  , loadEvents
  , loadProjectionEvents
  , ensureEventsTable
  ) where

import Proem

import Core.Event.Event (Event, LoadedEvent, decodeEventPayloadJson, eventToWeakHead, weakHeadToEvent)
import Core.Event.EventStore (EventStore(..), EVENT_STORE, OptimisticLockInfo)
import Core.Event.Filter (Filter, false_, fold)
import Foreign (Foreign, MultipleErrors)
import Foreign as Foreign
import Data.Bifunctor (lmap)
import Unsafe.Coerce (unsafeCoerce)
import Util.Foreign.Native as Native
import Yoga.JSON as JSON
import Yoga.JSON (readImpl, writeImpl)
import Control.Monad.Except (runExcept)
import Data.Array (any, foldr, length, zip, (:), filter, find, drop, head)
import Data.Array as Array
import Data.DateTime.Instant (Instant, unInstant) as InstantBase
import Data.Either (Either(..))
import Data.Int (toNumber, fromString)
import Data.Maybe (Maybe(..))
import Data.UUID (genUUID, toString) as UUID
import Util.Type.Limit (Limit(..))
import Core.Mod.Time.Instant (Instant(..))
import Data.String (Pattern(..), Replacement(..), replaceAll, contains)
import Data.Traversable (traverse, for_)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Milliseconds(..), delay, error, throwError)
import Effect.Now as Now
import Foreign.Object as Object
import Infra.Client.Postgres.Postgres (READER_POSTGRES_STORE_CLIENT, READER_POSTGRES_STORE_LOCK_CLIENT)
import Infra.Client.Postgres.Postgres as Postgres
import Util.Log.Warn (warn)
import Run (AFF, EFFECT, Run, on, send)
import Run as Run
import Effect (Effect)
import Effect.Exception as Exception
import Type.Row (type (+))
import Core.Mod.Trace.Trace (READER_TRACE, Trace)
import Core.Mod.Trace.Id (AppendId)
import Util.Lexicon.EventStore (eventStore')
import Util.Type.Random (random)
import Core.Mod.Id.Id as Id
import Core.Exception.Index (EXCEPT_LOGIC)
import Effect.Exception (message, Error)

foreign import generateLockKeyStr :: Effect String

-- | Appends events to the EventStore.
-- | Returns `Nothing` exclusively when a concurrency conflict occurs:
-- | - Optimistic Concurrency Control (OCC) check fails (another process wrote first).
-- | - Rate limit is hit (another process is currently holding the lock).
-- | In both cases, the orchestrator is responsible for interpreting this `Nothing`
-- | to either trigger a retry or throw a domain-level exception.
appendEvents
  :: ∀ fx
   . Trace
  -> Array Event
  -> OptimisticLockInfo
  -> Run (EXCEPT_LOGIC + READER_POSTGRES_STORE_LOCK_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) (Maybe (Array LoadedEvent))
appendEvents traceContext events optimisticLockInfo = go 0
  where
  go retried = do
    length events == 0 ? (η $ Just []) ↔ do
      append <- random @AppendId

      let
        mStashedAt = traceContext.overriddenAt

        filter = optimisticLockInfo.filter ??⇒ false_

        finalTrace = traceContext { append = Just append }

        metaJson = writeImpl
          { trace:
              { run: finalTrace.run
              , append: finalTrace.append
              , cause: finalTrace.cause
              }
          }

        appendableEvents = events <#> \event ->
          { event
          , meta: metaJson
          }

        { where: whereClause, values: whereValues } = buildWhere filter 1

        optimisticCheck = (optimisticLockInfo.expectedMaxSequenceNumber ?? (\maxSeq -> "COALESCE(max_seq, 0) = " <> maxSeq) ⇔ "true")

        types = appendableEvents <#> (_.event ▷ eventToWeakHead ▷ _.type ▷ Foreign.unsafeToForeign)
        payloads = appendableEvents <#> (_.event ▷ eventToWeakHead ▷ _.payload)
        metas = appendableEvents <#> _.meta

        -- Simple parameters without concurrency protection
        jsonParamsSimple = whereValues
          <>
            [ Foreign.unsafeToForeign types
            , Foreign.unsafeToForeign payloads
            , Foreign.unsafeToForeign metas
            ]
          <> (mStashedAt ?? (\at -> [ Foreign.unsafeToForeign at ]) ⇔ [])

        -- CTE for when no strict concurrency is needed
        cteQueryTemplateSimple =
          """
            WITH context AS (SELECT MAX(n) as max_seq FROM events WHERE $whereClause)
            INSERT INTO events (type, payload, meta, at)
            SELECT unnest($$types::text[]), unnest($$payloads::jsonb[]), unnest($$metas::jsonb[]), $atValue
            FROM context
            WHERE $optimisticCheck
            RETURNING n::text, id::text, type::text, payload::text, meta::text, CAST(EXTRACT(EPOCH FROM at) * 1000 AS float8)::text AS at
            """

        cteQueryStrSimple = cteQueryTemplateSimple
          # replaceAll (Pattern "$whereClause") (Replacement whereClause)
          # replaceAll (Pattern "$$types") (Replacement ("$" <> show (length whereValues + 1)))
          # replaceAll (Pattern "$$payloads") (Replacement ("$" <> show (length whereValues + 2)))
          # replaceAll (Pattern "$$metas") (Replacement ("$" <> show (length whereValues + 3)))
          # replaceAll (Pattern "$atValue") (Replacement $ mStashedAt ?? (\_ -> "$" <> show (length whereValues + 4) <> "::timestamp") ⇔ "NOW() AT TIME ZONE 'UTC'")
          # replaceAll (Pattern "$optimisticCheck") (Replacement optimisticCheck)

        -- CTE for strict concurrency protection
        cteQueryTemplateEnriched =
          """
            WITH context AS (SELECT MAX(n) as max_seq FROM events WHERE $whereClause)
              , registry_cross_check AS (
                  SELECT count(*) as cnt 
                  FROM cco.append_intents other
                  JOIN cco.append_intents me ON me.intent_id = $intentId
                  WHERE ((other.events @? $jsonFilterStr::jsonpath) OR ($incomingEventsJsonArr::jsonb @? other.context))
                    AND other.intent_id != $intentId
                    AND other.lock_key < me.lock_key
              )
            INSERT INTO events (type, payload, meta, at)
            SELECT unnest($$types::text[]), unnest($$payloads::jsonb[]), unnest($$metas::jsonb[]), $atValue
            FROM context
            WHERE $optimisticCheck
             AND (SELECT cnt FROM registry_cross_check) = 0
            RETURNING n::text, id::text, type::text, payload::text, meta::text, CAST(EXTRACT(EPOCH FROM at) * 1000 AS float8)::text AS at
            """

        cteQueryStrEnriched = cteQueryTemplateEnriched
          # replaceAll (Pattern "$whereClause") (Replacement whereClause)
          # replaceAll (Pattern "$intentId") (Replacement ("$" <> show (length whereValues + 1)))
          # replaceAll (Pattern "$jsonFilterStr") (Replacement ("$" <> show (length whereValues + 2)))
          # replaceAll (Pattern "$incomingEventsJsonArr") (Replacement ("$" <> show (length whereValues + 3)))
          # replaceAll (Pattern "$$types") (Replacement ("$" <> show (length whereValues + 4)))
          # replaceAll (Pattern "$$payloads") (Replacement ("$" <> show (length whereValues + 5)))
          # replaceAll (Pattern "$$metas") (Replacement ("$" <> show (length whereValues + 6)))
          # replaceAll (Pattern "$atValue") (Replacement $ mStashedAt ?? (\_ -> "$" <> show (length whereValues + 7) <> "::timestamp") ⇔ "NOW() AT TIME ZONE 'UTC'")
          # replaceAll (Pattern "$optimisticCheck") (Replacement optimisticCheck)

        -- CCO (CONTEXT COLLISION OBSERVER) REGISTRY PREP
        jsonFilterStr = buildJsonPath filter
        incomingEventsForLock = appendableEvents <#> \ev -> writeImpl { type: (_.event ▷ eventToWeakHead ▷ _.type) ev, payload: (_.event ▷ eventToWeakHead ▷ _.payload) ev }
        incomingEventsJsonArr = writeImpl incomingEventsForLock

        requiresStrictConcurrencyProtection = optimisticLockInfo.requiresStrictConcurrencyProtection

      resOrErr <-
        if not requiresStrictConcurrencyProtection then do
          Postgres.withStoreTxConnectionHandle \txStore -> do
            executeAppendCte txStore cteQueryStrSimple jsonParamsSimple >>= case _ of
              Left err -> η (Left err)
              Right cteRows -> η (Right cteRows)
        else do
          uuid <- Run.liftEffect UUID.genUUID
          lockKey <- Run.liftEffect generateLockKeyStr
          let intentId = UUID.toString uuid

          let
            jsonParamsEnriched = whereValues
              <> [ Foreign.unsafeToForeign intentId, Foreign.unsafeToForeign jsonFilterStr, Foreign.unsafeToForeign (JSON.writeJSON incomingEventsJsonArr) ]
              <> [ Foreign.unsafeToForeign types, Foreign.unsafeToForeign payloads, Foreign.unsafeToForeign metas ]
              <> (mStashedAt ?? (\at -> [ Foreign.unsafeToForeign at ]) ⇔ [])

          Postgres.withStoreLockNoTxConnectionHandle \txStoreLock -> do
            lockResOrErr <- registerIntentAndSieve txStoreLock intentId lockKey (Foreign.unsafeToForeign (JSON.writeJSON incomingEventsJsonArr)) jsonFilterStr

            case lockResOrErr of
              Left err -> do
                _ <- Postgres.tryQuery txStoreLock "SELECT pg_advisory_unlock($1::bigint)" [ Foreign.unsafeToForeign lockKey ]
                η (Left err)
              Right false -> do
                _ <- Postgres.tryQuery txStoreLock "SELECT pg_advisory_unlock($1::bigint)" [ Foreign.unsafeToForeign lockKey ]
                η (Right []) -- Empty array will trigger 'Nothing' and application-level retry
              Right true -> do
                Postgres.withStoreTxConnectionHandle \txStore -> do
                  -- 3. Atomic CTE (Enriched OCC Check & Append)
                  resCte <- executeAppendCte txStore cteQueryStrEnriched jsonParamsEnriched

                  -- 4. Opportunistic GC
                  gcActiveContexts txStoreLock intentId lockKey
                  -- 5. Release session lock
                  _ <- Postgres.tryQuery txStoreLock "SELECT pg_advisory_unlock($1::bigint)" [ Foreign.unsafeToForeign lockKey ]

                  case resCte of
                    Left err -> η (Left err)
                    Right cteRows -> η (Right cteRows)

      case resOrErr of
        Left err | (contains (Pattern "42P01") (message err) || contains (Pattern "does not exist") (message err)) && retried == 0 -> do
          ensureEventsTable
          go 1
        Left err | contains (Pattern "23505") (message err) || contains (Pattern "duplicate key") (message err) -> do
          η Nothing
        Left err -> ʌ' $ throwError err
        Right cteRows -> do
          if length cteRows == 0 then η Nothing
          else case parseAppendedEvents cteRows of
            Left err -> ʌ' $ throwError err
            Right appendedEvents -> η (Just appendedEvents)

loadEvents
  :: ∀ fx
   . Filter
  -> Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) (Array LoadedEvent)
loadEvents filter = do
  let
    { where: whereClause, values: whereValues } = buildWhere filter 1

    -- TODO: -> (at, tie_break, n) pour insertion/"remplacement" (i.e. insertion de la nouvelle version ou du nouveau event, archivage de l'ancien via meta), 
    -- avec tie_break lexicographique (e.g. "am" entre "a" et "b", et ainsi de suite... 
    -- on peut placer encore quelque chose entre "a" et "am", comme "aa" 
    -- (attention à ne pas tomber sur des cas de voisinage strict comme "a" et "a0", car on ne peut pas insérer sinon -> "a0" aurait dû être "a00" lors de son insertion): 
    -- toujours selon at et non selon n)
    -- Attention aussi à bien adapter le check (max_n ne fonctionnera plus)
    -- Note: CAST(... AS float8) prevents the pg Node driver from mapping Postgres 'numeric' 
    -- to JS String (because it could be very large). This ensures Argonaut receives a JS Number, 
    -- allowing 'Instant' readImpl to pass.
    queryStr =
      "SELECT n::text, id::text, type::text, payload::text, meta::text, CAST(EXTRACT(EPOCH FROM at) * 1000 AS float8)::text AS at FROM events WHERE "
        <> whereClause
        <> " ORDER BY events.n ASC" -- Fix: events.n forces numeric sorting instead of alias string sorting

  queryEvents queryStr whereValues

loadProjectionEvents
  :: ∀ fx
   . String
  -> Limit Int
  -> Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) (Array LoadedEvent)
loadProjectionEvents lastSequenceNumber limit = go 0
  where
  maxRetries = 10

  go retried = do
    let
      whereClause = "n >= $1 AND (xact < horizon.min_xact OR at < NOW() - INTERVAL '1 minute')"

      { queryStrAfter, limitParams } = case limit of
        Finite l -> { queryStrAfter: "ORDER BY events.n ASC LIMIT $2", limitParams: [ Foreign.unsafeToForeign (toNumber l) ] }
        Infinite -> { queryStrAfter: "ORDER BY events.n ASC", limitParams: [] }

      jsonParams = [ Foreign.unsafeToForeign lastSequenceNumber ] <> limitParams

      -- Note: CAST(... AS float8) is required to parse 'at' as a JS Number instead of a String.
      queryStrBefore =
        """
        WITH horizon AS (SELECT pg_snapshot_xmin(pg_current_snapshot())::text::bigint as min_xact)
        SELECT n::text, id::text, type::text, payload::text, meta::text, CAST(EXTRACT(EPOCH FROM at) * 1000 AS float8)::text AS at 
        FROM events, horizon 
        WHERE 
        """

      queryStr = queryStrBefore <> whereClause <> "\n" <> queryStrAfter

    eventsWithCheckpoint <- queryEvents queryStr jsonParams

    now <- ʌ' $ ʌ Now.now

    let
      maybeCheckpointEvent = find (\e -> e.sequenceNumber == lastSequenceNumber) eventsWithCheckpoint
      events = filter (\e -> e.sequenceNumber /= lastSequenceNumber) eventsWithCheckpoint

      checkpointEvent = case maybeCheckpointEvent of
        Just e -> Real e
        Nothing -> Imaginary lastSequenceNumber

    if hasGap now checkpointEvent events then do
      if retried >= maxRetries then do
        warn $ "Gap detected in events. Max retries (" <> show maxRetries <> ") reached. Assuming rolled-back transaction and proceeding."
        η events
      else do
        warn $ "Gap detected in events. Retrying (" <> show (retried + 1) <> "/" <> show maxRetries <> ")..."
        ʌ' $ delay $ Milliseconds 100.0
        go $ retried + 1
    else
      η events

type SequenceNumber = String

data GapEvent = Imaginary SequenceNumber | Real LoadedEvent

hasGap :: InstantBase.Instant -> GapEvent -> Array LoadedEvent -> Boolean
hasGap now checkpointEvent events =
  let
    allEvents = checkpointEvent : (Real <$> events)

    windowMs = 60_000.0

    consecutiveGaps =
      zip allEvents (drop 1 allEvents)
        # any \(e1 /\ e2) ->
            let
              s1 = case e1 of
                Imaginary s -> s
                Real ev -> ev.sequenceNumber
              s2 = case e2 of
                Imaginary s -> s
                Real ev -> ev.sequenceNumber
            in
              case fromString s1, fromString s2 of
                Just n1, Just n2 ->
                  let
                    isGap = n2 - n1 > 1
                    (Milliseconds nowMs) = InstantBase.unInstant now

                    isRecent = case e2 of
                      Real ev2 ->
                        let
                          (Instant e2At_) = ev2.at
                          (Milliseconds atMs) = InstantBase.unInstant e2At_
                        in
                          (nowMs - atMs) < windowMs
                      Imaginary _ -> false
                  in
                    isGap && isRecent

                _, _ -> false
  in
    consecutiveGaps

type RawDbRow =
  { n :: String
  , id :: String
  , type :: String
  , payload :: String
  , meta :: String
  , at :: String
  }

queryEvents
  :: ∀ fx
   . String
  -> Array Foreign
  -> Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) (Array LoadedEvent)
queryEvents queryStr params = go 0
  where
  go retried = do
    res <- Postgres.tryQueryStore queryStr params
    case res of
      Left err | (contains (Pattern "42P01") (message err) || contains (Pattern "does not exist") (message err)) && retried == 0 -> do
        ensureEventsTable
        go 1
      Left err -> ʌ' $ throwError $ error $ "Failed to execute events query: " <> Exception.message err
      Right rows -> do
        let rawRows = (unsafeCoerce :: Array Foreign -> Array RawDbRow) rows

        let
          parseFastRow obj = do
            atJson <- lmap (\err -> error $ "Failed to parse at JSON: " <> err) $ Native.parseJSON obj.at
            payloadJson <- lmap (\err -> error $ "Failed to parse payload JSON: " <> err) $ Native.parseJSON obj.payload
            metaJson <- lmap (\err -> error $ "Failed to parse meta JSON: " <> err) $ Native.parseJSON obj.meta
            event <- lmap (\err -> error $ "Failed to parse event payload: " <> show err) $ decodeEventPayloadJson obj.type payloadJson
            meta <- lmap (\err -> error $ "Failed to parse event meta: " <> show err) $ runExcept (readImpl metaJson)
            at <- lmap (\err -> error $ "Failed to parse event at: " <> show err) $ runExcept (readImpl atJson)

            η
              { sequenceNumber: obj.n
              , id: Id.unsafeFromString obj.id
              , at
              , event
              , meta
              }

        case traverse parseFastRow rawRows of
          Left err -> ʌ' $ throwError $ error $ "Failed to construct events: " <> Exception.message err
          Right events -> η events

buildWhere :: Filter -> Int -> { where :: String, values :: Array Foreign }
buildWhere filter = fold
  onByType
  onByPayloadPair
  onTrue
  onFalse
  onAnd
  onOr
  onNot
  filter
  where
  onByType type_ idx =
    { where: "type = $" <> show idx
    , values: [ writeImpl type_ ]
    }

  onByPayloadPair pathParts value idx =
    let
      nestedJson =
        foldr
          (\k acc -> writeImpl (Object.singleton k acc))
          (writeImpl value)
          pathParts
    in
      { where: "payload @> $" <> show idx <> "::jsonb"
      , values: [ nestedJson ]
      }

  onTrue _ =
    { where: "true"
    , values: []
    }

  onFalse _ =
    { where: "false"
    , values: []
    }

  onAnd f g idx =
    let
      r1 = f idx
      r2 = g (idx + length r1.values)
    in
      { where: "(" <> r1.where <> " AND " <> r2.where <> ")"
      , values: r1.values <> r2.values
      }

  onOr f g idx =
    let
      r1 = f idx
      r2 = g (idx + length r1.values)
    in
      { where: "(" <> r1.where <> " OR " <> r2.where <> ")"
      , values: r1.values <> r2.values
      }

  onNot f idx =
    let
      r1 = f idx
    in
      { where: "NOT (" <> r1.where <> ")"
      , values: r1.values
      }

buildJsonPath :: Filter -> String
buildJsonPath filter = "$ ? ("
  <> fold
    onByType
    onByPayloadPair
    onTrue
    onFalse
    onAnd
    onOr
    onNot
    filter
  <> ")"
  where
  onByType type_ =
    "@.type == " <> JSON.writeJSON (writeImpl type_)

  onByPayloadPair pathParts value =
    let
      pathStr = Array.intercalate "." pathParts
    in
      "@.payload." <> pathStr <> " == " <> JSON.writeJSON (writeImpl value)

  onTrue = "1 == 1"

  onFalse = "1 == 0"

  onAnd f g = "(" <> f <> " && " <> g <> ")"

  onOr f g = "(" <> f <> " || " <> g <> ")"

  onNot f = "!(" <> f <> ")"

ensureEventsTable :: ∀ fx. Run (READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx) Ɩ
ensureEventsTable = do
  let
    queries =
      [ "CREATE EXTENSION IF NOT EXISTS pgx_ulid;"
      , "CREATE SCHEMA IF NOT EXISTS cco;"
      , """
        CREATE UNLOGGED TABLE IF NOT EXISTS cco.append_intents (
            intent_id VARCHAR PRIMARY KEY,
            lock_key BIGINT NOT NULL,
            context JSONPATH NOT NULL,
            events JSONB NOT NULL
        );
        """
      , """
        CREATE TABLE IF NOT EXISTS events (
            n BIGSERIAL PRIMARY KEY,
            id CHAR(26) NOT NULL DEFAULT LOWER(gen_ulid()::text) UNIQUE,
            type VARCHAR NOT NULL,
            payload JSONB NOT NULL,
            meta JSONB NOT NULL,
            at TIMESTAMP(6) NOT NULL DEFAULT (NOW() AT TIME ZONE 'UTC'),
            xact BIGINT DEFAULT pg_current_xact_id()::text::bigint
        );
        """
      , "CREATE INDEX IF NOT EXISTS idx_events_type ON events(type);"
      , "CREATE INDEX IF NOT EXISTS idx_events_at ON events(at);"
      , "CREATE INDEX IF NOT EXISTS idx_events_payload ON events USING gin(payload);"
      , "CREATE INDEX IF NOT EXISTS idx_events_meta ON events USING gin(meta);"
      ]

  for_ queries \q ->
    ø $ Postgres.queryStore q []

interpretEventStore
  :: ∀ fx a
   . Run (EVENT_STORE + EXCEPT_LOGIC + READER_POSTGRES_STORE_LOCK_CLIENT + READER_POSTGRES_STORE_CLIENT + READER_TRACE + EFFECT + AFF + fx) a
  -> Run (EXCEPT_LOGIC + READER_POSTGRES_STORE_LOCK_CLIENT + READER_POSTGRES_STORE_CLIENT + READER_TRACE + EFFECT + AFF + fx) a
interpretEventStore = Run.interpret (on eventStore' handle send)
  where
  handle :: ∀ fx' a'. EventStore a' -> Run (EXCEPT_LOGIC + READER_POSTGRES_STORE_LOCK_CLIENT + READER_POSTGRES_STORE_CLIENT + EFFECT + AFF + fx') a'
  handle (AppendEvents trace events optimisticLockInfo next) = do
    res <- appendEvents trace events optimisticLockInfo
    η $ next res
  handle (LoadEvents filter next) = do
    events <- loadEvents filter
    η $ next events

-- | Generates a unique, transaction-scoped lock ID from a PostgreSQL sequence.
-- | This ID will represent the current context transaction in the registry.
-- | Parses the JSON rows returned by the append CTE into strongly-typed `LoadedEvent` records.
-- | It also handles the runtime conversion of the serialized event payload back to the business domain representation.
parseAppendedEvents :: Array Foreign -> Either Error (Array LoadedEvent)
parseAppendedEvents rows = do
  let
    parseRow json = do
      obj <-
        runExcept (readImpl json)
          :: Either MultipleErrors RawDbRow
      let
        parseJson str = lmap (\err -> pure (Foreign.ForeignError err)) $ Native.parseJSON str
      payloadJson <- parseJson obj.payload
      metaJson <- parseJson obj.meta
      atJson <- parseJson obj.at

      event <- weakHeadToEvent { type: obj.type, payload: payloadJson }
      meta <- runExcept (readImpl metaJson)
      at <- runExcept (readImpl atJson)

      η
        { sequenceNumber: obj.n
        , id: Id.unsafeFromString obj.id
        , at
        , event
        , meta
        }

  case traverse parseRow rows of
    Left err -> Left $ error $ "Failed to parse appended event from database: " <> show err <> " (rows: " <> JSON.writeJSON (writeImpl rows) <> ")"
    Right appendedEvents -> Right appendedEvents

executeAppendCte :: ∀ fx. Postgres.TxConnectionHandle -> String -> Array Foreign -> Run (AFF + EFFECT + fx) (Either Error (Array Foreign))
executeAppendCte txStore cteQueryStr jsonParams =
  Postgres.tryQuery txStore cteQueryStr jsonParams

registerIntentAndSieve :: ∀ fx. Postgres.NoTxConnectionHandle -> String -> String -> Foreign -> String -> Run (AFF + EFFECT + fx) (Either Error Boolean)
registerIntentAndSieve txStoreLock intentId lockKey incomingEventsJsonArr jsonFilterStr = do
  -- Acquire our intent's session lock immediately
  _ <- Postgres.tryQuery txStoreLock "SELECT pg_advisory_lock($1::bigint)" [ Foreign.unsafeToForeign lockKey ]

  let
    lockQuery =
      """
        WITH collisions AS (
            SELECT lock_key as colliding_key FROM cco.append_intents
            WHERE (events @? $2::jsonpath) OR ($3::jsonb @? context)
        ),
        zombie_check AS (
            SELECT colliding_key, pg_try_advisory_lock(colliding_key) as is_zombie
            FROM collisions
        ),
        active_collisions AS (
            SELECT colliding_key FROM zombie_check WHERE NOT is_zombie
        ),
        cleanup_zombies AS (
            DELETE FROM cco.append_intents
            WHERE lock_key IN (SELECT colliding_key FROM zombie_check WHERE is_zombie)
        ),
        release_zombie_locks AS (
            SELECT pg_advisory_unlock(colliding_key)
            FROM zombie_check WHERE is_zombie
        ),
        insertion AS (
            INSERT INTO cco.append_intents (intent_id, lock_key, context, events)
            SELECT $1, $4::bigint, $2::jsonpath, $3::jsonb 
            WHERE (SELECT count(*) FROM active_collisions) < 1
            RETURNING true as inserted
        )
        SELECT COALESCE((SELECT inserted FROM insertion), false) as success
      """

  lockRows <- Postgres.tryQuery txStoreLock lockQuery
    [ Foreign.unsafeToForeign intentId
    , Foreign.unsafeToForeign jsonFilterStr
    , Foreign.unsafeToForeign (JSON.writeJSON incomingEventsJsonArr)
    , Foreign.unsafeToForeign lockKey
    ]

  case lockRows of
    Left err -> η (Left err)
    Right lockRows' -> case head lockRows' of
      Nothing -> η (Left (error "Failed to parse rate limit check outer"))
      Just rowJson' -> case runExcept (readImpl rowJson') :: Either MultipleErrors { success :: Boolean } of
        Right obj' -> do
          if not obj'.success then do
            _ <- Postgres.tryQuery txStoreLock "SELECT pg_advisory_unlock($1::bigint)" [ Foreign.unsafeToForeign lockKey ]
            η (Right false)
          else
            η (Right true)
        Left _ -> case runExcept (readImpl rowJson') :: Either MultipleErrors { success :: String } of
          Right objStr -> do
            if objStr.success /= "t" && objStr.success /= "true" then do
              _ <- Postgres.tryQuery txStoreLock "SELECT pg_advisory_unlock($1::bigint)" [ Foreign.unsafeToForeign lockKey ]
              η (Right false)
            else
              η (Right true)
          Left err2 -> η (Left (error ("Failed to parse rate limit check inner: " <> JSON.writeJSON rowJson' <> " err: " <> show err2)))

gcActiveContexts :: ∀ fx. Postgres.NoTxConnectionHandle -> String -> String -> Run (AFF + EFFECT + fx) Ɩ
gcActiveContexts txStoreLock intentId _ = ø $ Postgres.tryQuery txStoreLock "DELETE FROM cco.append_intents WHERE intent_id = $1" [ Foreign.unsafeToForeign intentId ]
