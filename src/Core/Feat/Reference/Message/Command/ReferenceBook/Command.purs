module Core.Feat.Reference.Message.Command.ReferenceBook.Command
  (ReferenceBook(..)
  ) where

import Proem

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.ReferenceBook.Decide (decide)
import Core.Feat.Reference.Message.Command.ReferenceBook.Filter (filter)
import Core.Feat.Reference.Message.Command.ReferenceBook.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.ReferenceBook.Play (play)
import Core.Feat.Reference.Message.Command.ReferenceBook.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.ReferenceBook.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Feat.Reference.Message.Query.VerifyBookUniqueness.VerifyBookUniqueness (verifyBookUniqueness)

newtype ReferenceBook = ReferenceBook Payload

derive instance Newtype ReferenceBook _
derive instance Generic ReferenceBook _
derive newtype instance Random ReferenceBook
derive newtype instance WriteForeign ReferenceBook
derive newtype instance ReadForeign ReferenceBook

instance Reflect ReferenceBook where
  reflectName = reflectConstructorName @ReferenceBook

instance IsProtectedAgainstConcurrency ReferenceBook where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    ReferenceBook
    State
    Fields
    Payload
    Result
  where
  description = "Reference a book"

  handle payload = do
    _ <- verifyBookUniqueness { name: payload.name, authors: payload.authors, editor: payload.editor }

    defaultHandle @ReferenceBook (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  