module Core.Mod.Token.Token where

import Control.Monad.Except as Control.Monad.Except
import Proem

import Core.Exception.Exception (inj, throw')
import Core.Mod.Token.Exception (InvalidToken(..), TokenExceptionRow)
import Data.Argonaut.Decode (JsonDecodeError(..), class DecodeJson, decodeJson)
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.String (Pattern(..), Replacement(..), replaceAll, trim)
import Data.String as String
import Data.Variant (Variant)
import Partial.Unsafe (unsafeCrashWith)
import Run (Run)
import Run.Except (Except)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (class ToString, toString)
import Util.Type.Uuid (Uuid, generateV4Uuid, parseUuid)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON as Yoga.JSON
import Foreign as Foreign

newtype Token (a :: Type) = Token Uuid

make_ :: ∀ a. String -> Either (Variant (TokenExceptionRow ())) (Token a)
make_ str = do
  let
    str' = trim str
    formattedStr = String.length str' == 32 ? insertHyphens str' ↔ str'

  case parseUuid formattedStr of
    Just uuid -> Right $ Token uuid
    Nothing -> Left $ inj $ InvalidToken str

make
  :: ∀ r n fx a
   . Newtype n (Variant (TokenExceptionRow r))
  => String
  -> Run (exceptLogic ∷ Except n | fx) (Token a)
make str = case make_ str of
  Left e -> throw' e
  Right token -> η token

unsafeFromString
  :: ∀ a
   . String
  -> Token a
unsafeFromString str =
  let
    str' = String.length str == 32 ? insertHyphens str ↔ str
  in
    case parseUuid str' of
      Just uuid -> Token uuid
      Nothing -> unsafeCrashWith "Invalid UUID"

unsafeFromUuid
  :: ∀ a
   . Uuid
  -> Token a
unsafeFromUuid = Token

instance ToString (Token a) where
  toString (Token uuid) = replaceAll (Pattern "-") (Replacement "") (toString uuid)

derive instance Eq (Token a)
derive instance Ord (Token a)
derive newtype instance Show (Token a)

instance EncodeJson (Token a) where
  encodeJson (Token uuid) = encodeJson (toString (Token uuid))

instance DecodeJson (Token a) where
  decodeJson json = do
    str <- decodeJson json
    case make_ str of
      Right token -> Right token
      Left _ -> Left $ TypeMismatch "UUID (no hyphens)"

instance Yoga.JSON.ReadForeign (Token a) where
  readImpl f = do
    str <- Yoga.JSON.readImpl f
    case make_ str of
      Right token -> pure token
      Left _ -> Foreign.fail (Foreign.ForeignError "UUID (no hyphens)")

instance IsRefinedType (Token a) (TokenExceptionRow ()) where
  makeFromJson _ json = do
    case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json) of
      Left _ -> Left $ inj $ InvalidToken "Not a string"
      Right str -> make_ str

instance Random (Token a) where
  random = do
    uuid <- ʌ generateV4Uuid
    η $ Token uuid

insertHyphens :: String -> String
insertHyphens s =
  let
    p1 = String.take 8 s
    p2 = String.take 4 (String.drop 8 s)
    p3 = String.take 4 (String.drop 12 s)
    p4 = String.take 4 (String.drop 16 s)
    p5 = String.drop 20 s
  in
    p1 <> "-" <> p2 <> "-" <> p3 <> "-" <> p4 <> "-" <> p5



instance Yoga.JSON.WriteForeign (Token a) where
  writeImpl (Token u) = Yoga.JSON.writeImpl (toString u)
