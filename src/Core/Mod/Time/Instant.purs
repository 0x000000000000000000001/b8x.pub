module Core.Mod.Time.Instant where

import Control.Monad.Except as Control.Monad.Except
import Proem
import Data.Identity as Data.Identity
import Data.List.NonEmpty as Data.List.NonEmpty

import Data.Argonaut.Decode (JsonDecodeError(..), class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.DateTime.Instant (Instant, unInstant, instant) as Base
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Data.Time.Duration (Milliseconds(..))
import Core.Exception.Exception (inj)
import Core.Mod.Projection.SearchIndex (class IsScalar)
import Core.Mod.Time.Exception (InvalidInstant(..), TimeExceptionRow)
import Core.Util.Validation (class IsRefinedType)
import Util.Type.Random (class Random, random)
import Yoga.JSON as Yoga.JSON
import Foreign as Foreign
import Control.Alt ((<|>))

newtype Instant = Instant Base.Instant

derive newtype instance Eq Instant
derive newtype instance Ord Instant
derive newtype instance Show Instant
derive newtype instance Yoga.JSON.WriteForeign Instant


instance IsScalar Instant

foreign import _toIsoString :: Number -> String
foreign import _toHumanParisDate :: Number -> String
foreign import _toSendyScheduleDate :: Number -> String

foreign import _parseIsoString :: (Number -> Maybe Number) -> (Maybe Number) -> String -> Maybe Number

parseIsoString :: String -> Maybe Number
parseIsoString = _parseIsoString Just Nothing

toIsoString :: Instant -> String
toIsoString (Instant i) =
  let
    (Milliseconds ms) = Base.unInstant i
  in
    _toIsoString ms

toHumanParisDate :: Instant -> String
toHumanParisDate (Instant i) =
  let
    (Milliseconds ms) = Base.unInstant i
  in
    _toHumanParisDate ms

instance EncodeJson Instant where
  encodeJson (Instant i) =
    let
      (Milliseconds ms) = Base.unInstant i
    in
      encodeJson ms

instance DecodeJson Instant where
  decodeJson json = do
    let 
      decodeNumber = do
        num <- decodeJson json
        -- If the timestamp is between the year 1971 (31_536_000s) and 9000 (221_845_660_800s),
        -- it's very likely in seconds. Otherwise, we assume it's already in milliseconds.
        let ms = if num >= 31_536_000.0 && num < 221_845_660_800.0 then num * 1000.0 else num
        case Base.instant (Milliseconds ms) of
          Nothing -> Left (TypeMismatch "Invalid instant bounds")
          Just i -> Right (Instant i)
          
      decodeString = do
        str <- decodeJson json
        case parseIsoString str of
          Nothing -> Left (TypeMismatch "Invalid instant format")
          Just num -> case Base.instant (Milliseconds num) of
            Nothing -> Left (TypeMismatch "Invalid instant bounds")
            Just i -> Right (Instant i)
            
    case decodeNumber of
      Right i -> Right i
      Left _ -> decodeString

instance Yoga.JSON.ReadForeign Instant where
  readImpl f = do
    let 
      readNumber = do
        num <- Yoga.JSON.readImpl f
        let ms = if num >= 31_536_000.0 && num < 221_845_660_800.0 then num * 1000.0 else num
        case Base.instant (Milliseconds ms) of
          Nothing -> Foreign.fail (Foreign.ForeignError "Invalid instant bounds")
          Just i -> pure (Instant i)
          
      readString = do
        str <- Yoga.JSON.readImpl f
        case parseIsoString str of
          Nothing -> Foreign.fail (Foreign.ForeignError "Invalid instant format")
          Just num -> case Base.instant (Milliseconds num) of
            Nothing -> Foreign.fail (Foreign.ForeignError "Invalid instant bounds")
            Just i -> pure (Instant i)
            
    readNumber <|> readString

instance Random Instant where
  random = do
    num <- random
    η $ Instant $ (Base.instant $ Milliseconds num) ??⇒ bottom

instance IsRefinedType Instant (TimeExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json :: Control.Monad.Except.ExceptT (Data.List.NonEmpty.NonEmptyList Foreign.ForeignError) Data.Identity.Identity Instant) of
    Right i -> Right i
    Left _ -> Left $ inj InvalidInstant

toSendyScheduleDate :: Instant -> String
toSendyScheduleDate (Instant i) =
  let (Milliseconds ms) = Base.unInstant i
  in _toSendyScheduleDate ms
