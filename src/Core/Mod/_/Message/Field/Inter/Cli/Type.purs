module Core.Mod.Message.Field.Inter.Cli.Type where

import Config.PublicConfig (READER_PUBLIC_CONFIG)
import Core.Event.EventStore (EVENT_STORE)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Feat.Effect.Cache (CACHE)
import Core.Feat.Effect.Generate (GENERATE)
import Core.Feat.Effect.Mail (MAIL)
import Core.Feat.Effect.Newsletter (NEWSLETTER)
import Core.Feat.Effect.RateLimit (RATE_LIMIT)
import Core.Feat.Effect.Sleep (SLEEP)
import Core.Message.Command.Handle.Download (DOWNLOAD)
import Core.Message.Command.Handle.Upload (UPLOAD)
import Core.Message.Queue (QUEUE)
import Core.Mod.Projection.Index (PROJECTION_READ)
import Core.Mod.Trace.Trace (READER_TRACE)
import Foreign (Foreign)
import Inter.Cli.Util.Prefix (READER_CLI_PREFIX)
import Run (Run, AFF, EFFECT)
import Type.Row (type (+))
import Util.Type.Row.Row (class RowKeysOverlap)
import Util.Type.Type (reflectName)
import Yoga.JSON (class WriteForeign, writeImpl)
import Core.Message.Command.Command (class IsCommand)

type LogPrefix = String

type BaseCliFx fx =
  ( AFF
      + EFFECT
      + EVENT_STORE
      + EXCEPT_LOGIC
      + QUEUE
      + PROJECTION_READ
      + DOWNLOAD
      + UPLOAD
      + NEWSLETTER
      + RATE_LIMIT
      + CACHE
      + MAIL
      + GENERATE
      + SLEEP
      + READER_TRACE
      + READER_PUBLIC_CONFIG
      + READER_CLI_PREFIX
      + fx
  )

data CustomCliActResult
  = UserInput String
  | TriggerCommand String Foreign

triggerCommand
  :: ∀ @cmd state fields payload a
   . IsCommand cmd state fields payload a
  => CustomCliActResult
triggerCommand = TriggerCommand (reflectName @cmd) (writeImpl ({} :: {}))

triggerCommandWith
  :: ∀ @cmd state fields payload a r
   . IsCommand cmd state fields payload a
  => RowKeysOverlap r fields
  => WriteForeign (Record r)
  => { | r }
  -> CustomCliActResult
triggerCommandWith record = TriggerCommand (reflectName @cmd) (writeImpl record)

type CustomCliAct fx = LogPrefix -> Run (BaseCliFx fx) CustomCliActResult
