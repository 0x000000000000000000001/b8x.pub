module Core.Feat.Review.Message.Command.WriteArticle.Command
  ( WriteArticle(..)
  ) where

import Proem

import Core.Exception.Exception (throw)
import Core.Feat.Review.Message.Command.WriteArticle.Decide (decide)
import Core.Feat.Review.Message.Command.WriteArticle.Filter (filter)
import Core.Feat.Review.Message.Command.WriteArticle.Payload (Payload, Fields)
import Core.Feat.Review.Message.Command.WriteArticle.Play (play)
import Core.Feat.Review.Message.Command.WriteArticle.Projection.Projection (findArticleBySlug)
import Core.Feat.Review.Message.Command.WriteArticle.Result (Result, toResult)
import Core.Feat.Review.Message.Command.WriteArticle.State (State, initialState)
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.VerifyArticleLegacyIdUniqueness (verifyArticleLegacyIdUniqueness)
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.VerifyArticleSlugUniqueness (verifyArticleSlugUniqueness)
import Core.Message.Command.Command (class IsCommand, class IsProtectedAgainstConcurrency, defaultMaxConcurrencyRetries, ConcurrencyPriority(..), defaultCheckLoadedEvents, defaultHandle)
import Core.Mod.Article.Slug.Exception (InvalidSlug(..))
import Core.Mod.Article.Slug.Slug (make_)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype WriteArticle = WriteArticle Payload

derive instance Newtype WriteArticle _
derive instance Generic WriteArticle _
derive newtype instance Random WriteArticle
derive newtype instance WriteForeign WriteArticle
derive newtype instance ReadForeign WriteArticle

instance Reflect WriteArticle where
  reflectName = reflectConstructorName @WriteArticle

instance IsProtectedAgainstConcurrency WriteArticle where
  priority = Safe
  maxRetries = defaultMaxConcurrencyRetries
  baseRetryDelayMs = 100

instance
  IsCommand
    WriteArticle
    State
    Fields
    Payload
    Result
  where
  description = "Write an article"

  handle payload = do
    slug' <- case payload.slug of
      Just providedSlug -> η providedSlug
      Nothing -> case make_ true (toString payload.title) of
        Left _ -> throw $ InvalidSlug (toString payload.title)
        Right generated ->
          let
            findUnique iter = do
              let candidateStr = toString generated <> (iter == 1 ? "" ↔ "-" <> show iter)
              case make_ true candidateStr of
                Left _ -> throw $ InvalidSlug candidateStr
                Right candidate -> do
                  occupant <- findArticleBySlug candidate
                  case occupant of
                    Just _ -> findUnique (iter + 1)
                    Nothing -> η candidate
          in
            findUnique 1

    _ <- verifyArticleSlugUniqueness { slug: slug' }
    _ <- verifyArticleLegacyIdUniqueness { legacyId: payload.legacyId }

    defaultHandle @WriteArticle (Just filter) defaultCheckLoadedEvents initialState play decide toResult payload

  