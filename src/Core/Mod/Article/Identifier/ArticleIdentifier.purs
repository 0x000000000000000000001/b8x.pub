module Core.Mod.Article.Identifier.ArticleIdentifier where

import Proem

import Control.Monad.Except as Control.Monad.Except
import Core.Exception.Exception (inj)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Identifier.Exception (IdentifierExceptionRow, InvalidArticleIdentifier(..))
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Yoga.JSON as Yoga.JSON

data ArticleIdentifier
  = Id ArticleId
  | Slug Slug

derive instance Eq ArticleIdentifier
derive instance Generic ArticleIdentifier _

instance Show ArticleIdentifier where
  show (Id id) = "Id " <> show id
  show (Slug slug) = "Slug " <> show slug

instance WriteForeign ArticleIdentifier where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign ArticleIdentifier where
  readImpl = genericReadImplWithDefaultOpt

instance Random ArticleIdentifier where
  random = do
    b <- random
    if b then Id <$> random
    else Slug <$> random

instance IsRefinedType ArticleIdentifier (IdentifierExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json) of
    Right val -> Right val
    Left _ -> Left $ inj $ InvalidArticleIdentifier $ Yoga.JSON.writeJSON json

