module Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.VerifyAuthorUniqueness where

import Proem

import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Payload (Payload)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Query (VerifyAuthorUniqueness(..))
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.Result (Result)
import Core.Message.Query.Query as Query
import Core.Mod.Projection.Index (PROJECTION_READ)
import Run (Run)
import Type.Row (type (+))
import Core.Mod.Trace.Trace (READER_TRACE)
import Core.Feat.Effect.Generate (GENERATE)

verifyAuthorUniqueness
  :: ∀ fx
   . Payload
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
       Result
verifyAuthorUniqueness = Query.handleWithCache ◁ VerifyAuthorUniqueness
