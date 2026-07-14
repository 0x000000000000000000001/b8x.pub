module Core.Mod.Time.Month where

import Foreign as Foreign
import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Util.Validation (class IsRefinedType)
import Core.Mod.Projection.SearchIndex (class IsScalar)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Date.Component as Date
import Data.Enum (fromEnum, toEnum)
import Data.Newtype (class Newtype)
import Effect.Random (randomInt)
import Util.Type.Random (class Random)

newtype Month = Month Date.Month

derive instance Newtype Month _
derive newtype instance Eq Month
derive newtype instance Ord Month
derive newtype instance Show Month

instance WriteForeign Month where
  writeImpl (Month m) = writeImpl (fromEnum m)

instance ReadForeign Month where
  readImpl json = do
    int <- readImpl json
    case toEnum int of
      Just m -> pure (Month m)
      Nothing -> Foreign.fail (Foreign.ForeignError "Invalid Month")

instance Random Month where
  random = do
    int <- ʌ $ randomInt 1 12
    case toEnum int of
      Just m -> pure (Month m)
      Nothing -> pure (Month bottom)

instance IsRefinedType Month (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left error -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error }
    Right value -> Right value

instance IsScalar Month



