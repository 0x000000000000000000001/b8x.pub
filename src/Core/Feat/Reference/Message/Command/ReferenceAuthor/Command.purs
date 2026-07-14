module Core.Feat.Reference.Message.Command.ReferenceAuthor.Command
  (ReferenceAuthor(..)
  ) where

import Proem

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Decide (decide)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Filter (filter)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Play (play)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.ReferenceAuthor.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Feat.Reference.Message.Query.VerifyAuthorUniqueness.VerifyAuthorUniqueness (verifyAuthorUniqueness)

newtype ReferenceAuthor = ReferenceAuthor Payload

derive instance Newtype ReferenceAuthor _
derive instance Generic ReferenceAuthor _
derive newtype instance Random ReferenceAuthor
derive newtype instance WriteForeign ReferenceAuthor
derive newtype instance ReadForeign ReferenceAuthor

instance Reflect ReferenceAuthor where
  reflectName = reflectConstructorName @ReferenceAuthor

instance IsProtectedAgainstConcurrency ReferenceAuthor where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    ReferenceAuthor
    State
    Fields
    Payload
    Result
  where
  description = "Reference an author"

  handle payload = do
    _ <- verifyAuthorUniqueness { name: payload.name, legacyIds: payload.legacyIds }

    defaultHandle @ReferenceAuthor (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  