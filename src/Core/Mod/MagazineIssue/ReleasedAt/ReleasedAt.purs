module Core.Mod.MagazineIssue.ReleasedAt.ReleasedAt where

import Proem

import Control.Monad.Except as Control.Monad.Except
import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Mod.Time.Month (Month)
import Core.Mod.Time.Year (Year)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Effect.Random (randomInt)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)

type Date =
  { month :: Month
  , year :: Year
  }

data ReleasedAt
  = Single Date
  | Span { start :: Date, end :: Date }

derive instance Generic ReleasedAt _
derive instance Eq ReleasedAt
derive instance Ord ReleasedAt

instance Show ReleasedAt where
  show = genericShow

instance Random ReleasedAt where
  random = do
    isSpan <- ʌ $ randomInt 0 1
    d1 <- random
    d2 <- random
    if isSpan == 1 then
      η $ Span { start: d1, end: d2 }
    else
      η $ Single d1

instance IsRefinedType ReleasedAt (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left error -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error }
    Right a -> Right a

instance WriteForeign ReleasedAt where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign ReleasedAt where
  readImpl = genericReadImplWithDefaultOpt
