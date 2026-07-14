module Core.Feat.Reference.Message.Command.DereferenceBook.Command
  (DereferenceBook(..)
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.DereferenceBook.Decide (decide)
import Core.Feat.Reference.Message.Command.DereferenceBook.Filter (filter)
import Core.Feat.Reference.Message.Command.DereferenceBook.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.DereferenceBook.Play (play)
import Core.Feat.Reference.Message.Command.DereferenceBook.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.DereferenceBook.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype DereferenceBook = DereferenceBook Payload

derive instance Newtype DereferenceBook _
derive instance Generic DereferenceBook _
derive newtype instance Random DereferenceBook
derive newtype instance WriteForeign DereferenceBook
derive newtype instance ReadForeign DereferenceBook

instance Reflect DereferenceBook where
  reflectName = reflectConstructorName @DereferenceBook

instance IsProtectedAgainstConcurrency DereferenceBook where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    DereferenceBook
    State
    Fields
    Payload
    Result
  where
  description = "Dereference a book"

  handle = defaultHandle @DereferenceBook (Just filter) defaultCheckLoadedEvents initialState play decide toResult

  