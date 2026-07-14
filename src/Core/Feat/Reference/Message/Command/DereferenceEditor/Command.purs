module Core.Feat.Reference.Message.Command.DereferenceEditor.Command
  (DereferenceEditor(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Decide (decide)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Filter (filter)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Play (play)
import Core.Feat.Reference.Message.Command.DereferenceEditor.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.DereferenceEditor.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype DereferenceEditor = DereferenceEditor Payload

derive instance Newtype DereferenceEditor _
derive instance Generic DereferenceEditor _
derive newtype instance Random DereferenceEditor
derive newtype instance WriteForeign DereferenceEditor
derive newtype instance ReadForeign DereferenceEditor

instance Reflect DereferenceEditor where
  reflectName = reflectConstructorName @DereferenceEditor

instance IsProtectedAgainstConcurrency DereferenceEditor where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    DereferenceEditor
    State
    Fields
    Payload
    Result
  where
  description = "Dereference an editor"

  handle = defaultHandle @DereferenceEditor (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  