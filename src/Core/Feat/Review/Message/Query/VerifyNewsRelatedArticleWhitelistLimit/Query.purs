module Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Payload (Payload, Fields)
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Projection.Projection (Article, findArticles)
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Result (Result)
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Article.Exception.TooManyArticlesAddedToNewsRelatedWhitelist (TooManyArticlesAddedToNewsRelatedWhitelist(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyNewsRelatedArticleWhitelistLimit = VerifyNewsRelatedArticleWhitelistLimit Payload

derive instance Newtype VerifyNewsRelatedArticleWhitelistLimit _
derive instance Generic VerifyNewsRelatedArticleWhitelistLimit _
derive newtype instance Random VerifyNewsRelatedArticleWhitelistLimit
derive newtype instance WriteForeign VerifyNewsRelatedArticleWhitelistLimit
derive newtype instance ReadForeign VerifyNewsRelatedArticleWhitelistLimit

instance Reflect VerifyNewsRelatedArticleWhitelistLimit where
  reflectName = reflectConstructorName @VerifyNewsRelatedArticleWhitelistLimit

instance IsQuery VerifyNewsRelatedArticleWhitelistLimit State Fields Payload Result where
  description = "Verify news related article whitelist limit"

  cacheStrategy _ = do
    hash <- getReadModelHash @Article Nothing
    η $ defaultCached hash

  handle (VerifyNewsRelatedArticleWhitelistLimit _) = do
    page <- findArticles (defaultFindOpt { limit = Finite 12 })

    when
      (Array.length page.items >= 12)
      (throw $ TooManyArticlesAddedToNewsRelatedWhitelist 12)

    η {}
