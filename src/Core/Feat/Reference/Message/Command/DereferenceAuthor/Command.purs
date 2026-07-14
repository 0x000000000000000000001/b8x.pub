module Core.Feat.Reference.Message.Command.DereferenceAuthor.Command
  (DereferenceAuthor(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Decide (decide)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Filter (filter)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Play (play)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.DereferenceAuthor.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype DereferenceAuthor = DereferenceAuthor Payload

derive instance Newtype DereferenceAuthor _
derive instance Generic DereferenceAuthor _
derive newtype instance Random DereferenceAuthor
derive newtype instance WriteForeign DereferenceAuthor
derive newtype instance ReadForeign DereferenceAuthor

instance Reflect DereferenceAuthor where
  reflectName = reflectConstructorName @DereferenceAuthor

instance IsProtectedAgainstConcurrency DereferenceAuthor where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    DereferenceAuthor
    State
    Fields
    Payload
    Result
  where
  description = "Dereference an author"

  handle = defaultHandle @DereferenceAuthor (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  