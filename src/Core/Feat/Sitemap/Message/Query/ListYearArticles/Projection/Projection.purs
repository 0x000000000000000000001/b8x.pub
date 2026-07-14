module Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Data.Array as Array
import Control.Monad.Except as Control.Monad.Except

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_, findOneByKey)
import Core.Mod.Projection.Finder.Filter (class IsFilter, StrictlyEquals(..), by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, get, patch)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Time.Year (Year, fromInstant)
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Slug.Slug (Slug)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)
import Core.Util.Validation (class IsRefinedType)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Exception.InvalidArticleFilter (InvalidArticleFilter(..), InvalidArticleFilterRow)
import Data.Either (Either(..))
import Core.Exception.Exception (inj)

data ListYearArticlesProjection

instance
  IsProjection
    ListYearArticlesProjection
    "listYearArticles"
    "listYearArticlesProjectionWriteOps"
    (LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS ())
    "listYearArticlesProjectionReadSyncProject"
    { listYearArticles :: Article }
    { listYearArticles :: ArticleIndexNeeds }
    { listYearArticles :: Record ArticleSortRow }
  where
  indexNeeds =
    { listYearArticles:
        { id: rawIndexOnly
        , year: rawIndexOnly
        , slug: rawIndexOnly
        , seo:
            { updatedAt: rawIndexOnly
            }
        }
    }

  play = coerce @(LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS ()) play

type LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS fx = (listYearArticlesProjectionWriteOps :: ProjectionWriteOps | fx)
type LIST_YEAR_ARTICLES_PROJECTION_READ_SYNC_PROJECT fx = (listYearArticlesProjectionReadSyncProject :: SyncProject | fx)

type LIST_YEAR_ARTICLES_PROJECTION_READ_FIND fx =
  LIST_YEAR_ARTICLES_LIST_YEAR_ARTICLES_PROJECTION_READ_FIND
    + fx

-- Model 

---- Article 

type ArticleSortRow =
  ( year :: Ɩ
  , id :: Ɩ
  , slug :: Ɩ
  , "seo.updatedAt" :: Ɩ
  )

type ArticleSortCriteria = SortCriteria Article

instance IsPair ArticleKey Article ArticleRecord ArticleIndexNeeds ArticleSortRow "listYearArticles" "listYearArticles" "listYearArticlesListYearArticlesProjectionReadFind" ListYearArticlesProjection where
  toKey (Article { id, slug }) = ArticleKey { id: Just id, slug: Just slug }

  single = false

newtype Article = Article ArticleRecord

type ArticleRecord =
  { id :: ArticleId
  , year :: Year
  , slug :: Slug
  , seo ::
      { updatedAt :: Instant
      }
  }

type ArticleIndexNeeds =
  { id :: RawIndexOnly ArticleId
  , year :: RawIndexOnly Year
  , slug :: RawIndexOnly Slug
  , seo ::
      { updatedAt :: RawIndexOnly Instant
      }
  }

derive instance Newtype Article _
derive instance Generic Article _
derive instance Eq Article
derive instance Ord Article
derive newtype instance ReadForeign Article
derive newtype instance WriteForeign Article

instance Random Article where
  random = do
    id <- random
    year <- random
    slug <- random
    updatedAt <- random

    η $ Article
      { id
      , year
      , slug
      , seo: { updatedAt }
      }

newtype ArticleKey = ArticleKey { id :: Maybe ArticleId, slug :: Maybe Slug }

derive instance Newtype ArticleKey _
derive instance Eq ArticleKey
derive instance Ord ArticleKey

instance ToAliasedPrimary ArticleKey where
  toAliasedPrimary (ArticleKey k) = { primary: maybe "" toString k.id, aliases: maybe [] (Array.singleton <<< toString) k.slug }

-- Find

type LIST_YEAR_ARTICLES_LIST_YEAR_ARTICLES_PROJECTION_READ_FIND fx = (listYearArticlesListYearArticlesProjectionReadFind :: Find Article | fx)
type LIST_YEAR_ARTICLES_LIST_YEAR_ARTICLES_PROJECTION_READ fx =
  LIST_YEAR_ARTICLES_LIST_YEAR_ARTICLES_PROJECTION_READ_FIND
    + LIST_YEAR_ARTICLES_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticleById :: ∀ fx. ArticleId -> Run (LIST_YEAR_ARTICLES_LIST_YEAR_ARTICLES_PROJECTION_READ + fx) (Maybe Article)
findArticleById id = findOneByKey (ArticleKey { id: Just id, slug: Nothing })

-- Filter

data ArticleFilter
  = ArticleHasYear Year
  | ArticleAnd { left :: ArticleFilter, right :: ArticleFilter }
  | ArticleOr { left :: ArticleFilter, right :: ArticleFilter }
  | ArticleNot ArticleFilter
  | ArticleTrue
  | ArticleFalse

derive instance Eq ArticleFilter
derive instance Ord ArticleFilter
derive instance Generic ArticleFilter _

instance Show ArticleFilter where
  show filter = genericShow filter

instance WriteForeign ArticleFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign ArticleFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra ArticleFilter where
  ff = ArticleFalse
  tt = ArticleTrue
  not = ArticleNot
  implies a b = (ArticleNot a) || b
  conj left right = ArticleAnd { left, right }
  disj left right = ArticleOr { left, right }

instance IsFilter ArticleFilter Article where
  compile _ (ArticleHasYear year) = by @"year" StrictlyEquals year

  compile e (ArticleAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (ArticleOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (ArticleNot f) = not (compile e f)

  compile _ ArticleTrue = Base.True
  compile _ ArticleFalse = Base.False

instance IsRefinedType ArticleFilter (InvalidArticleFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidArticleFilter
    Right filter -> η filter

instance Random ArticleFilter where
  random = ArticleHasYear <$> random

findArticles
  :: ∀ fx
   . FindOpt ArticleFilter ArticleId Article
  -> Run (LIST_YEAR_ARTICLES_LIST_YEAR_ARTICLES_PROJECTION_READ + fx) (Page Article)
findArticles opt = findMany_ opt { after = opt.after <#> (\id -> ArticleKey { id: Just id, slug: Nothing }) ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
play { event, at } = case event of
  ArticleWritten payload -> onArticleWritten at payload
  ArticleDiscarded payload -> onArticleDiscarded payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
  MagazineIssueReferenced _ -> ηι
  MagazineIssueDereferenced _ -> ηι
  EditorReferenced _ -> ηι
  EditorDereferenced _ -> ηι
  UserEmailChanged _ -> ηι
  UserRegistered _ -> ηι
  UserUnregistered _ -> ηι
  ArticleFeaturedOnFrontPage _ -> ηι
  ArticleQuoted _ -> ηι
  NewsTopicAdded _ -> ηι
  NewsTopicRemoved _ -> ηι
  ArticleAddedToNewsRelatedWhitelist _ -> ηι
  ArticleRemovedFromNewsRelatedWhitelist _ -> ηι
  ArticleAddedToNewsRelatedBlacklist _ -> ηι
  ArticleRemovedFromNewsRelatedBlacklist _ -> ηι
  ArticleRead _ -> ηι
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

---- Listeners

onArticleWritten :: ∀ fx. Instant -> ArticleWritten.Payload -> Run (LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten at { id, slug } = do
  let y = fromInstant at
  mArticle <- get (ArticleKey { id: Just id, slug: Nothing })
  case mArticle of
    Nothing -> add $ Article { id, year: y, slug, seo: { updatedAt: at } }
    Just _ -> patch (ArticleKey { id: Just id, slug: Nothing }) \(Article r) -> Article (r { slug = slug, seo = { updatedAt: at } })

onArticleDiscarded :: ∀ fx. ArticleDiscarded.Payload -> Run (LIST_YEAR_ARTICLES_PROJECTION_WRITE_OPS fx) Ɩ
onArticleDiscarded { article } = delete (ArticleKey { id: Just article, slug: Nothing })


