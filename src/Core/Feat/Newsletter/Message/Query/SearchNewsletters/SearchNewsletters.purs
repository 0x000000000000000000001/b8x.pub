module Core.Feat.Newsletter.Message.Query.SearchNewsletters.SearchNewsletters where

import Proem

import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Payload (Payload)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Query (SearchNewsletters(..))
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Result (Result)
import Core.Message.Query.Query as Query
import Core.Mod.Projection.Index (PROJECTION_READ)
import Run (Run)
import Type.Row (type (+))
import Core.Mod.Trace.Trace (READER_TRACE)
import Core.Feat.Effect.Generate (GENERATE)

searchNewsletters
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
searchNewsletters = Query.handleWithCache ◁ SearchNewsletters
