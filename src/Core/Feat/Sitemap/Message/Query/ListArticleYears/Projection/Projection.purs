module Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_, findOneByKey)
import Core.Mod.Projection.Finder.Filter (class IsFilter, StrictlyEquals(..), by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, get, patch)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Time.Year (Year(..), fromInstant)
import Data.Enum (fromEnum)
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Core.Util.Validation (class IsRefinedType)
import Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Exception.InvalidArticleYearFilter (InvalidArticleYearFilter(..), InvalidArticleYearFilterRow)
import Data.Either (Either(..))
import Core.Exception.Exception (inj)

data ListArticleYearsProjection

instance
  IsProjection
    ListArticleYearsProjection
    "listArticleYears"
    "listArticleYearsProjectionWriteOps"
    (LIST_ARTICLE_YEARS_PROJECTION_WRITE_OPS ())
    "listArticleYearsProjectionReadSyncProject"
    { listArticleYears :: ArticleYear }
    { listArticleYears :: ArticleYearIndexNeeds }
    { listArticleYears :: Record ArticleYearSortRow }
  where
  indexNeeds =
    { listArticleYears:
        { year: rawIndexOnly
        , seo:
            { updatedAt: rawIndexOnly
            }
        }
    }

  play = coerce @(LIST_ARTICLE_YEARS_PROJECTION_WRITE_OPS ()) play

type LIST_ARTICLE_YEARS_PROJECTION_WRITE_OPS fx = (listArticleYearsProjectionWriteOps :: ProjectionWriteOps | fx)
type LIST_ARTICLE_YEARS_PROJECTION_READ_SYNC_PROJECT fx = (listArticleYearsProjectionReadSyncProject :: SyncProject | fx)

type LIST_ARTICLE_YEARS_PROJECTION_READ_FIND fx =
  LIST_ARTICLE_YEARS_LIST_ARTICLE_YEARS_PROJECTION_READ_FIND
    + fx

-- Model 

---- ArticleYear 

type ArticleYearSortRow =
  ( year :: Ɩ
  , "seo.updatedAt" :: Ɩ
  )

type ArticleYearSortCriteria = SortCriteria ArticleYear

instance IsPair ArticleYearKey ArticleYear ArticleYearRecord ArticleYearIndexNeeds ArticleYearSortRow "listArticleYears" "listArticleYears" "listArticleYearsListArticleYearsProjectionReadFind" ListArticleYearsProjection where
  toKey (ArticleYear { year }) = ArticleYearKey year

  single = false

newtype ArticleYear = ArticleYear ArticleYearRecord

type ArticleYearRecord =
  { year :: Year
  , seo ::
      { updatedAt :: Instant
      }
  }

type ArticleYearIndexNeeds =
  { year :: RawIndexOnly Year
  , seo ::
      { updatedAt :: RawIndexOnly Instant
      }
  }

derive instance Newtype ArticleYear _
derive instance Generic ArticleYear _
derive instance Eq ArticleYear
derive instance Ord ArticleYear
derive newtype instance ReadForeign ArticleYear
derive newtype instance WriteForeign ArticleYear

instance Random ArticleYear where
  random = do
    year <- random
    updatedAt <- random

    η $ ArticleYear
      { year
      , seo: { updatedAt }
      }

newtype ArticleYearKey = ArticleYearKey Year

derive instance Newtype ArticleYearKey _
derive newtype instance Eq ArticleYearKey
derive newtype instance Ord ArticleYearKey

instance ToAliasedPrimary ArticleYearKey where
  toAliasedPrimary (ArticleYearKey (Year y)) = { primary: show (fromEnum y), aliases: [] }

-- Find

type LIST_ARTICLE_YEARS_LIST_ARTICLE_YEARS_PROJECTION_READ_FIND fx = (listArticleYearsListArticleYearsProjectionReadFind :: Find ArticleYear | fx)
type LIST_ARTICLE_YEARS_LIST_ARTICLE_YEARS_PROJECTION_READ fx =
  LIST_ARTICLE_YEARS_LIST_ARTICLE_YEARS_PROJECTION_READ_FIND
    + LIST_ARTICLE_YEARS_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticleYearByYear :: ∀ fx. Year -> Run (LIST_ARTICLE_YEARS_LIST_ARTICLE_YEARS_PROJECTION_READ + fx) (Maybe ArticleYear)
findArticleYearByYear year = findOneByKey (ArticleYearKey year)

-- Filter

data ArticleYearFilter
  = ArticleYearHasYear Year
  | ArticleYearAnd { left :: ArticleYearFilter, right :: ArticleYearFilter }
  | ArticleYearOr { left :: ArticleYearFilter, right :: ArticleYearFilter }
  | ArticleYearNot ArticleYearFilter
  | ArticleYearTrue
  | ArticleYearFalse

derive instance Eq ArticleYearFilter
derive instance Ord ArticleYearFilter
derive instance Generic ArticleYearFilter _

instance Show ArticleYearFilter where
  show filter = genericShow filter

instance WriteForeign ArticleYearFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign ArticleYearFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra ArticleYearFilter where
  ff = ArticleYearFalse
  tt = ArticleYearTrue
  not = ArticleYearNot
  implies a b = (ArticleYearNot a) || b
  conj left right = ArticleYearAnd { left, right }
  disj left right = ArticleYearOr { left, right }

instance IsFilter ArticleYearFilter ArticleYear where
  compile _ (ArticleYearHasYear year) = by @"year" StrictlyEquals year

  compile e (ArticleYearAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (ArticleYearOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (ArticleYearNot f) = not (compile e f)

  compile _ ArticleYearTrue = Base.True
  compile _ ArticleYearFalse = Base.False

instance IsRefinedType ArticleYearFilter (InvalidArticleYearFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidArticleYearFilter
    Right filter -> η filter

instance Random ArticleYearFilter where
  random = ArticleYearHasYear <$> random

findArticleYears
  :: ∀ fx
   . FindOpt ArticleYearFilter Year ArticleYear
  -> Run (LIST_ARTICLE_YEARS_LIST_ARTICLE_YEARS_PROJECTION_READ + fx) (Page ArticleYear)
findArticleYears opt = findMany_ opt { after = opt.after <#> ArticleYearKey ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (LIST_ARTICLE_YEARS_PROJECTION_WRITE_OPS fx) Ɩ
play { event, at } = case event of
  ArticleWritten payload -> onArticleWritten at payload
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
  ArticleDiscarded _ -> ηι
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

onArticleWritten :: ∀ fx. Instant -> ArticleWritten.Payload -> Run (LIST_ARTICLE_YEARS_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten at _ = do
  let y = fromInstant at
  let key = ArticleYearKey y

  mArticleYear <- get key
  case mArticleYear of
    Nothing -> add $ ArticleYear { year: y, seo: { updatedAt: at } }
    Just _ -> patch key \(ArticleYear r) -> ArticleYear (r { seo = { updatedAt: at } })


