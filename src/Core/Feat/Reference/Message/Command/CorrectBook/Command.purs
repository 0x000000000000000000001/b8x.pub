module Core.Feat.Reference.Message.Command.CorrectBook.Command
  ( CorrectBook(..)
  , CorrectBookAliasRow
  ) where



import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Feat.Reference.Message.Command.CorrectBook.Decide (decide)
import Core.Feat.Reference.Message.Command.CorrectBook.Filter (filter)
import Core.Feat.Reference.Message.Command.CorrectBook.Payload (Payload, Fields)
import Core.Feat.Reference.Message.Command.CorrectBook.Play (play)
import Core.Feat.Reference.Message.Command.CorrectBook.Result (Result, toResult)
import Core.Feat.Reference.Message.Command.CorrectBook.State (State, initialState)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype CorrectBook = CorrectBook Payload

derive instance Newtype CorrectBook _
derive instance Generic CorrectBook _
derive newtype instance Random CorrectBook
derive newtype instance WriteForeign CorrectBook
derive newtype instance ReadForeign CorrectBook

instance Reflect CorrectBook where
  reflectName = reflectConstructorName @CorrectBook

instance IsProtectedAgainstConcurrency CorrectBook where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    CorrectBook
    State
    Fields
    Payload
    Result
  where
  description = "Correct a book's information"

  handle payload = do
    defaultHandle @CorrectBook (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

type CorrectBookAliasRow r =
  ( "CorrectABook" :: CorrectBook
  , "CorrigeLivre" :: CorrectBook
  , "CorrigerLivre" :: CorrectBook
  , "CorrectionLivre" :: CorrectBook
  | r
  )
