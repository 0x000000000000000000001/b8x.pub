module Core.Mod.Time.Year where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Util.Validation (class IsRefinedType)
import Core.Mod.Projection.SearchIndex (class IsScalar)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), fromJust)
import Data.Date.Component as Date
import Data.Enum (fromEnum, toEnum)
import Data.Newtype (class Newtype)
import Effect.Random (randomInt)
import Partial.Unsafe (unsafePartial)
import Util.Type.Random (class Random)
import Core.Mod.Time.Instant (Instant(..))
import Data.DateTime.Instant as Data.DateTime.Instant
import Data.DateTime as Data.DateTime
import Data.Date as Data.Date
import Yoga.JSON as JSON
import Foreign as Foreign

newtype Year = Year Date.Year

unsafeFromInt :: Int -> Year
unsafeFromInt int = Year $ unsafePartial fromJust $ toEnum int

fromInstant :: Instant -> Year
fromInstant (Instant i) =
  let
    dt = Data.DateTime.Instant.toDateTime i
    y = Data.Date.year (Data.DateTime.date dt)
  in
    Year y

derive instance Newtype Year _
derive newtype instance Eq Year
derive newtype instance Ord Year
derive newtype instance Show Year

instance WriteForeign Year where
  writeImpl (Year y) = writeImpl (fromEnum y)

instance ReadForeign Year where
  readImpl f = do
    int <- JSON.readImpl f
    case toEnum int of
      Just y -> pure (Year y)
      Nothing -> Foreign.fail (Foreign.ForeignError "Invalid Year")

instance Random Year where
  random = do
    int <- ʌ $ randomInt (-1000) 2050
    case toEnum int of
      Just y -> pure (Year y)
      Nothing -> pure (Year bottom)

instance IsRefinedType Year (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left error -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error }
    Right value -> Right value

instance IsScalar Year
