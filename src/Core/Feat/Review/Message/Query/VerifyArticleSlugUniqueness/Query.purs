module Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Query where

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Payload (Payload, Fields)
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Projection.Projection (Article, ArticleKey(..), findArticleBySlug)
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Result (Result)
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Article.Exception.ArticleSlugAlreadyTaken (ArticleSlugAlreadyTaken(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyArticleSlugUniqueness = VerifyArticleSlugUniqueness Payload

derive instance Newtype VerifyArticleSlugUniqueness _
derive instance Generic VerifyArticleSlugUniqueness _
derive newtype instance Random VerifyArticleSlugUniqueness
derive newtype instance WriteForeign VerifyArticleSlugUniqueness
derive newtype instance ReadForeign VerifyArticleSlugUniqueness

instance Reflect VerifyArticleSlugUniqueness where
  reflectName = reflectConstructorName @VerifyArticleSlugUniqueness

instance IsQuery VerifyArticleSlugUniqueness State Fields Payload Result where
  description = "Verify that an article slug is unique"

  cacheStrategy (VerifyArticleSlugUniqueness { slug }) = do
    hash <- getReadModelHash @Article (Just (ArticleKey { id: Nothing, slug: Just slug }))
    η $ defaultCached hash

  handle (VerifyArticleSlugUniqueness payload) = do
    mArticle <- findArticleBySlug payload.slug
    case mArticle of
      Just _ -> throw $ ArticleSlugAlreadyTaken payload.slug
      Nothing -> η {}
