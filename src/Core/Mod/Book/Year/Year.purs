module Core.Mod.Book.Year.Year
  (Year(..)
  ) where

import Proem

import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValueRow)
import Core.Mod.Time.Year as Time
import Core.Util.Validation (class IsRefinedType, makeRecordFromJson)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Either (Either)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random, random)

newtype Year = Year
  { year :: Time.Year
  , approximately :: Boolean
  }

derive instance Newtype Year _
derive newtype instance Eq Year
derive newtype instance Ord Year
derive newtype instance Show Year
derive newtype instance ReadForeign Year
derive newtype instance WriteForeign Year

instance Random Year where
  random = do
    year <- random
    approximately <- random
    η $ Year { year, approximately }

instance IsRefinedType Year (MalformedPayloadValueRow ()) where
  makeFromJson sanitize json =
    Year <$> (makeRecordFromJson sanitize json :: Either _ { year :: Time.Year, approximately :: Boolean })
