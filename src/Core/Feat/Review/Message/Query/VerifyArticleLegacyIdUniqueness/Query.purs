module Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Query where

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Payload (Payload, Fields)
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Projection.Projection (Article, findArticleByLegacyId)
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Result (Result)
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Article.LegacyId.Exception.LegacyIdAlreadyTaken (LegacyIdAlreadyTaken(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype VerifyArticleLegacyIdUniqueness = VerifyArticleLegacyIdUniqueness Payload

derive instance Newtype VerifyArticleLegacyIdUniqueness _
derive instance Generic VerifyArticleLegacyIdUniqueness _
derive newtype instance Random VerifyArticleLegacyIdUniqueness
derive newtype instance WriteForeign VerifyArticleLegacyIdUniqueness
derive newtype instance ReadForeign VerifyArticleLegacyIdUniqueness

instance Reflect VerifyArticleLegacyIdUniqueness where
  reflectName = reflectConstructorName @VerifyArticleLegacyIdUniqueness

instance IsQuery VerifyArticleLegacyIdUniqueness State Fields Payload Result where
  description = "Verify that an article legacy ID is unique"

  cacheStrategy _ = do
    hash <- getReadModelHash @Article Nothing
    η $ defaultCached hash

  handle (VerifyArticleLegacyIdUniqueness payload) = case payload.legacyId of
    Just lId -> do
      mArticle <- findArticleByLegacyId lId
      case mArticle of
        Just _ -> throw $ LegacyIdAlreadyTaken lId
        Nothing -> η {}
    Nothing -> η {}
