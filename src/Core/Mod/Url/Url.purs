module Core.Mod.Url.Url
  (Url
  , make
  , make_
  , unsafeFromString
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as Yoga.JSON

import Core.Exception.Exception (inj, throw')
import Core.Mod.Url.Exception (InvalidUrl(..), UrlExceptionRow)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.String (trim)
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Data.Variant (Variant)
import Run (Run)
import Run.Except (Except)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (class ToString)

newtype Url = Url String

make_
  :: String
  -> Either (Variant (UrlExceptionRow ())) Url
make_ str = do
  let
    pattern = "^https?://(.*)"
    str' = trim str
  case regex pattern noFlags of
    Right r -> do
      test r str'
        ? (η $ Url str')
        ↔ (Left $ inj $ InvalidUrl str)
    Left _ -> Left $ inj $ InvalidUrl str

make
  :: ∀ r n fx
   . Newtype n (Variant (UrlExceptionRow r))
  => String
  -> Run (exceptLogic ∷ Except n | fx) Url
make str = case make_ str of
  Left e -> throw' e
  Right x -> η x

unsafeFromString :: String -> Url
unsafeFromString = Url

instance IsRefinedType Url (UrlExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj $ InvalidUrl $ Yoga.JSON.writeJSON json
    Right str -> make_ str

derive newtype instance Eq Url
derive newtype instance Ord Url
derive newtype instance Show Url
derive newtype instance WriteForeign Url
derive newtype instance ReadForeign Url
derive newtype instance ToString Url

instance Random Url where
  random = η $ Url "https://example.com/mock.png"
