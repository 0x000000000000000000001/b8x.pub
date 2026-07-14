module Core.Mod.NonEmptyString.NonEmptyString
  (NonEmptyString(..)
  , make
  , make_
  , unsafeFromString
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Exception.Exception (inj, throw')
import Core.Mod.NonEmptyString.Exception (EmptyString(..), NonEmptyStringExceptionRow)
import Core.Mod.Projection.Finder.Filter (class IsValidOp, EqualsUpToNormalization, Matches)
import Core.Mod.Projection.SearchIndex (class IsScalar, class IsText)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.String (trim)
import Data.Variant (Variant)
import Run (Run)
import Run.Except (Except)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (class ToString, toString)
import Util.Type.Ulid (generateUlid)

newtype NonEmptyString = NonEmptyString String

make_
  :: String
  -> Either (Variant (NonEmptyStringExceptionRow ())) NonEmptyString
make_ str = do
  let str' = trim str
  str' == "" ? (Left $ inj EmptyString) ↔ η $ NonEmptyString str'

make
  :: ∀ r n fx
   . Newtype n (Variant (NonEmptyStringExceptionRow r))
  => String
  -> Run (exceptLogic ∷ Except n | fx) NonEmptyString
make str = case make_ str of
  Left e -> throw' e
  Right s -> η s

unsafeFromString :: String -> NonEmptyString
unsafeFromString = NonEmptyString

instance IsRefinedType NonEmptyString (NonEmptyStringExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj EmptyString
    Right str -> make_ str

instance Random NonEmptyString where
  random = do
    ulid <- ʌ generateUlid
    η $ NonEmptyString (toString ulid)

instance IsScalar NonEmptyString
instance IsText NonEmptyString

instance IsValidOp Matches NonEmptyString
instance IsValidOp EqualsUpToNormalization NonEmptyString

derive instance Newtype NonEmptyString _
derive newtype instance Eq NonEmptyString
derive newtype instance Ord NonEmptyString
derive newtype instance Show NonEmptyString
derive newtype instance WriteForeign NonEmptyString
derive newtype instance ReadForeign NonEmptyString
derive newtype instance ToString NonEmptyString
