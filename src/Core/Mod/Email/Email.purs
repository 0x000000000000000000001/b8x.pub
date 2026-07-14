module Core.Mod.Email.Email
  (Email
  , make
  , make_
  , isValid
  , unsafeFromString
  ) where

import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as Yoga.JSON
import Proem

import Core.Exception.Exception (inj, throw')
import Core.Mod.Email.Exception (InvalidEmail(..), EmailExceptionRow)
import Core.Mod.Projection.SearchIndex (class IsScalar, class IsText)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..), isRight)
import Data.Newtype (class Newtype)
import Data.String (trim, toLower)
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Data.Variant (Variant)
import Run (Run)
import Run.Except (Except)
import Util.Type.Random (class Random)
import Util.Type.String.String (removeAccents)
import Util.Type.String.ToString (class ToString, toString)
import Util.Type.Ulid (generateUlid)

newtype Email = Email String

make_
  :: Boolean
  -> String
  -> Either (Variant (EmailExceptionRow ())) Email
make_ sanitize str = do
  let
    pattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)+$"
    str' = sanitize ? (sanitizeString str) ↔ str

  case regex pattern noFlags of
    Left _ -> Left $ inj $ InvalidEmail str
    Right r -> do
      test r str'
        ? (η $ Email str')
        ↔ (Left $ inj $ InvalidEmail str)

make
  :: ∀ r n fx
   . Newtype n (Variant (EmailExceptionRow r))
  => Boolean
  -> String
  -> Run (exceptLogic ∷ Except n | fx) Email
make sanitize str = case make_ sanitize str of
  Left e -> throw' e
  Right email -> η email

sanitizeString :: String -> String
sanitizeString = trim ▷ toLower ▷ removeAccents

isValid :: String -> Boolean
isValid str = isRight (make_ true str)

unsafeFromString :: String -> Email
unsafeFromString = Email

instance IsScalar Email
instance IsText Email

instance IsRefinedType Email (EmailExceptionRow ()) where
  makeFromJson sanitize json = case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json) of
    Left _ -> Left $ inj $ InvalidEmail $ Yoga.JSON.writeJSON json
    Right str -> make_ sanitize str

instance Random Email where
  random = do
    ulid <- ʌ generateUlid
    η $ Email $ (ulid # toString) <> "@email.com"

derive newtype instance Eq Email
derive newtype instance Ord Email
derive newtype instance Show Email
derive newtype instance Yoga.JSON.ReadForeign Email
derive newtype instance ToString Email



instance Yoga.JSON.WriteForeign Email where
  writeImpl (Email s) = Yoga.JSON.writeImpl s
