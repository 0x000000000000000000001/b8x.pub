module Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.Newsletter where

import Proem

import Control.Monad.Except as Control.Monad.Except
import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year (Year)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Effect.Class (class MonadEffect)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)

newtype NewsletterField = NewsletterField Newsletter

description :: String
description = "Newsletter target"

instance IsField NewsletterField Newsletter () where
  name = "Newsletter"

  description = description

  presence = Required

  sanitize = κ Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NewsletterField _
derive newtype instance ReadForeign NewsletterField
derive newtype instance WriteForeign NewsletterField
derive newtype instance Eq NewsletterField
derive newtype instance Show NewsletterField

data Newsletter
  = Month { month :: Month, year :: Year }
  | Id NewsletterId
  | Recent

derive instance Eq Newsletter
derive instance Ord Newsletter
derive instance Generic Newsletter _

instance Show Newsletter where
  show = genericShow

instance WriteForeign Newsletter where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign Newsletter where
  readImpl = genericReadImplWithDefaultOpt

instance Random Newsletter where
  random = do
    r <- random :: ∀ m. MonadEffect m => m Int
    case r `mod` 3 of
      0 -> do
        month <- random
        year <- random
        η $ Month { month, year }
      1 -> Id <$> random
      _ -> η Recent

instance IsRefinedType Newsletter (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left error -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error }
    Right value -> Right value
