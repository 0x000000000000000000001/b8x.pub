module Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Command
  ( AddNewsletterSubscriber(..)
  ) where

import Proem

import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultResult)
import Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Payload (Fields, Payload)
import Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.Result (Result)
import Core.Feat.Newsletter.Message.Command.AddNewsletterSubscriber.State (State)
import Core.Feat.Effect.Newsletter (addSubscriber)
import Core.Feat.Effect.RateLimit (consumeOrThrow, rateLimitBucket)
import Core.Mod.Trace.Trace (askSubject)
import Core.Mod.Trace.Subject (Subject(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype AddNewsletterSubscriber = AddNewsletterSubscriber Payload

derive instance Newtype AddNewsletterSubscriber _
derive instance Generic AddNewsletterSubscriber _
derive newtype instance Random AddNewsletterSubscriber
derive newtype instance WriteForeign AddNewsletterSubscriber
derive newtype instance ReadForeign AddNewsletterSubscriber

instance Reflect AddNewsletterSubscriber where
  reflectName = reflectConstructorName @AddNewsletterSubscriber

instance IsProtectedAgainstConcurrency AddNewsletterSubscriber where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    AddNewsletterSubscriber
    State
    Fields
    Payload
    Result
  where
  description = "Add a newsletter subscriber"

  handle payload = do
    mSubject <- askSubject
    let ip = case mSubject of
          Just (IdentifiedUiHuman s) -> s.ip
          Just (AnonymousUiHuman s) -> s.ip
          _ -> Nothing

    consumeOrThrow (rateLimitBucket "add_subscriber" { ip } 1) 100 3600

    ø $ addSubscriber payload.email

    η $ Right $ defaultResult ι

  