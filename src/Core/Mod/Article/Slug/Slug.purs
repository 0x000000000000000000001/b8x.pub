module Core.Mod.Article.Slug.Slug
  (Slug
  , make
  , make_
  , unsafeFromString
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as Yoga.JSON

import Core.Exception.Exception (inj, throw')
import Core.Mod.Article.Slug.Exception (InvalidSlug(..), SlugExceptionRow)
import Core.Mod.Projection.SearchIndex (class IsScalar, class IsText)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (noFlags)
import Data.Variant (Variant)
import Run (Run)
import Run.Except (Except)
import Util.Type.Random (class Random, random)
import Util.Type.String.String (slugify)
import Util.Type.String.ToString (class ToString)

newtype Slug = Slug String

sanitizeString :: String -> String
sanitizeString = slugify

make_
  :: Boolean
  -> String
  -> Either (Variant (SlugExceptionRow ())) Slug
make_ sanitize str = do
  let
    pattern = "^[a-z0-9_-]+$"
    str' = sanitize ? (sanitizeString str) ↔ str

  case regex pattern noFlags of
    Left _ -> Left $ inj $ InvalidSlug str
    Right r -> do
      test r str'
        ? (η $ Slug str')
        ↔ (Left $ inj $ InvalidSlug str)

make
  :: ∀ r n fx
   . Newtype n (Variant (SlugExceptionRow r))
  => Boolean
  -> String
  -> Run (exceptLogic ∷ Except n | fx) Slug
make sanitize str = case make_ sanitize str of
  Left e -> throw' e
  Right slug -> η slug

unsafeFromString :: String -> Slug
unsafeFromString = Slug

instance IsScalar Slug
instance IsText Slug

instance IsRefinedType Slug (SlugExceptionRow ()) where
  makeFromJson sanitize json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj $ InvalidSlug $ Yoga.JSON.writeJSON json
    Right str -> make_ sanitize str

instance Random Slug where
  random = do
    str <- random
    η $ Slug $ "slug-" <> (str # sanitizeString)

derive newtype instance Eq Slug
derive newtype instance Ord Slug
derive newtype instance Show Slug
derive newtype instance WriteForeign Slug
derive newtype instance ReadForeign Slug
derive newtype instance ToString Slug
