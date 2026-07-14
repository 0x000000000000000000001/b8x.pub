module Core.Mod.Html.Html
  (Html
  , NonEmptyHtml(..)
  , isEmpty
  , make
  , make_
  , unsafeFromString
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Exception.Exception (inj, throw')
import Core.Mod.Html.Exception (EmptyHtml(..), HtmlExceptionRow)
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
import Util.Html.Clean.Clean (untagExcept)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (class ToString, toString)
import Util.Type.Ulid (generateUlid)

type Html = String

newtype NonEmptyHtml = NonEmptyHtml String

isEmpty :: String -> Boolean
isEmpty str = trim (untagExcept ["img", "iframe", "video", "audio", "picture", "svg", "object", "embed", "math"] false str) == ""

make_
  :: String
  -> Either (Variant (HtmlExceptionRow ())) NonEmptyHtml
make_ str = do
  isEmpty str ? (Left $ inj EmptyHtml) ↔ η $ NonEmptyHtml str

make
  :: ∀ r n fx
   . Newtype n (Variant (HtmlExceptionRow r))
  => String
  -> Run (exceptLogic ∷ Except n | fx) NonEmptyHtml
make str = case make_ str of
  Left e -> throw' e
  Right s -> η s

unsafeFromString :: String -> NonEmptyHtml
unsafeFromString = NonEmptyHtml

instance IsRefinedType NonEmptyHtml (HtmlExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj EmptyHtml
    Right str -> make_ str

instance Random NonEmptyHtml where
  random = do
    ulid <- ʌ generateUlid
    η $ NonEmptyHtml ("<p>" <> toString ulid <> "</p>")

instance IsScalar NonEmptyHtml
instance IsText NonEmptyHtml

instance IsValidOp Matches NonEmptyHtml
instance IsValidOp EqualsUpToNormalization NonEmptyHtml

derive instance Newtype NonEmptyHtml _
derive newtype instance Eq NonEmptyHtml
derive newtype instance Ord NonEmptyHtml
derive newtype instance Show NonEmptyHtml
derive newtype instance WriteForeign NonEmptyHtml
derive newtype instance ReadForeign NonEmptyHtml
derive newtype instance ToString NonEmptyHtml
