module Core.Feat.Membership.Message.Command.RegisterUser.RegisterUser where

import Proem

import Core.Feat.Membership.Message.Command.RegisterUser.Command (RegisterUser(..))
import Core.Feat.Membership.Message.Command.RegisterUser.Payload (Payload)
import Core.Feat.Membership.Message.Command.RegisterUser.Result (Result)
import Core.Message.Command.Command (Result) as Command
import Core.Message.Command.Compose (child)
import Core.Message.Command.Handle.Exception (TooMuchConcurrency)
import Core.Message.Command.Handle.Handle (handleCommand)
import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Generate (GENERATE)
import Core.Feat.Effect.Sleep (SLEEP)
import Core.Feat.Effect.Mail (MAIL)
import Core.Feat.Effect.Newsletter (NEWSLETTER)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Queue (QUEUE)
import Core.Mod.Projection.Index (PROJECTION_READ)
import Core.Mod.Trace.Trace (READER_TRACE)
import Data.Either (Either)
import Run (Run)
import Type.Row (type (+))

childRegisterUser
  :: ∀ fx
   . Payload
  -> Run
       ( EVENT_STORE
           + EXCEPT_LOGIC
           + PROJECTION_READ
           + UPLOAD
           + NEWSLETTER
           + RATE_LIMIT
           + CACHE
           + MAIL
           + READER_TRACE
           + GENERATE
           + SLEEP
           + READER_PUBLIC_CONFIG
           
           + fx
       )
       (Either TooMuchConcurrency (Command.Result Result))
childRegisterUser = child @RegisterUser

registerUser
  :: ∀ fx
   . Payload
  -> Run
       ( EVENT_STORE
           + EXCEPT_LOGIC
           + QUEUE
           + PROJECTION_READ
           + UPLOAD
           + NEWSLETTER
           + RATE_LIMIT
           + CACHE
           + MAIL
           + GENERATE
           + SLEEP
           + READER_TRACE
           + READER_PUBLIC_CONFIG
           
           + fx
       )
       (Result)
registerUser = handleCommand true ◁ RegisterUser
