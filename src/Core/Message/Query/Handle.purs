module Core.Message.Query.Handle where

import Proem hiding (append)

import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Query.Query (class IsQuery)
import Core.Message.Query.Query as Query
import Core.Mod.Projection.Index (PROJECTION_READ)
import Run (Run)
import Type.Row (type (+))
import Core.Mod.Trace.Trace (READER_TRACE)
import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Core.Message.Query.Payload (Need(..)) as Payload
import Core.Message.Query.Result (Return(..)) as Result
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Generate (GENERATE)
import Yoga.JSON (class ReadForeign, class WriteForeign)

handleQuery
  :: ∀ @query state fields payload fx a
   . IsQuery query state fields payload a
  => ReadForeign a
  => WriteForeign a
  => query
  -> Run
       ( EVENT_STORE
           + EXCEPT_LOGIC
           + PROJECTION_READ
           + READER_PUBLIC_CONFIG
           + CACHE
           + GENERATE
           + READER_TRACE
           + fx
       )
       a
handleQuery query = Query.handleWithCache query

build :: ∀ opt innerNeeds value. Payload.Need opt innerNeeds -> value -> Result.Return value
build Payload.NotNeeded _ = Result.NotGivenBecauseNotNeeded
build (Payload.Needed _ _) c = Result.Given c
