module Core.Feat.Reference.Message.Command.ReferenceEditor.Command
  (ReferenceEditor(..)
  ) where

import Proem

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Decide (decide)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Filter (filter)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Play (play)
import Core.Feat.Reference.Message.Command.ReferenceEditor.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.ReferenceEditor.State (State, initialState)
import Core.Feat.Reference.Message.Query.VerifyEditorUniqueness.VerifyEditorUniqueness (verifyEditorUniqueness)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ReferenceEditor = ReferenceEditor Payload

derive instance Newtype ReferenceEditor _
derive instance Generic ReferenceEditor _
derive newtype instance Random ReferenceEditor
derive newtype instance WriteForeign ReferenceEditor
derive newtype instance ReadForeign ReferenceEditor

instance Reflect ReferenceEditor where
  reflectName = reflectConstructorName @ReferenceEditor

instance IsProtectedAgainstConcurrency ReferenceEditor where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    ReferenceEditor
    State
    Fields
    Payload
    Result
  where
  description = "Reference an editor"

  handle payload = do
    _ <- verifyEditorUniqueness { name: payload.name }

    defaultHandle @ReferenceEditor (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  