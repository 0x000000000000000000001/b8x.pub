module Core.Mod.Book.Year.Year
  ( Year(..)
  , InnerYear
  ) where

import Proem

import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValueRow)
import Core.Mod.Time.Year as Time
import Core.Util.Validation (class IsRefinedType, makeRecordFromJson, makeFromJson)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random, random)
import Core.Message.Field.Payload (class MakeNestedValue)

type InnerYear =
  { year :: Time.Year
  , approximately :: Boolean
  }

newtype Year = Year InnerYear

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
    case makeRecordFromJson sanitize json :: Either _ InnerYear of
      Right r -> Right (Year r)
      Left err -> case makeFromJson sanitize json :: Either _ Time.Year of
        Right y -> Right (Year { year: y, approximately: false })
        Left _ -> Left err

instance MakeNestedValue Year InnerYear where
  makeNestedValue_ _ buildRecord = do
    record <- buildRecord
    η $ Year record
