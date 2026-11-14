module Core.Feat.Reference.Message.Command.CorrectAuthor.Command
  ( CorrectAuthor(..)
  , CorrectAuthorAliasRow
  ) where

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Decide (decide)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Filter (filter)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Play (play)
import Core.Feat.Reference.Message.Command.CorrectAuthor.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.CorrectAuthor.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype CorrectAuthor = CorrectAuthor Payload

derive instance Newtype CorrectAuthor _
derive instance Generic CorrectAuthor _
derive newtype instance Random CorrectAuthor
derive newtype instance WriteForeign CorrectAuthor
derive newtype instance ReadForeign CorrectAuthor

instance Reflect CorrectAuthor where
  reflectName = reflectConstructorName @CorrectAuthor

instance IsProtectedAgainstConcurrency CorrectAuthor where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    CorrectAuthor
    State
    Fields
    Payload
    Result
  where
  description = "Correct an author's biography"

  handle payload = do
    defaultHandle @CorrectAuthor (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

type CorrectAuthorAliasRow r =
  ( "CorrectAnAuthor" :: CorrectAuthor
  , "CorrigeAuteur" :: CorrectAuthor
  , "CorrigerAuteur" :: CorrectAuthor
  , "CorrectionAuteur" :: CorrectAuthor
  | r
  )
