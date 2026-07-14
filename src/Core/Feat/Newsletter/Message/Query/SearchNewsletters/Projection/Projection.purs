module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.NewsletterScheduled.Payload as NewsletterScheduled
import Core.Mod.Newsletter.Id.Id (NewsletterId)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Finder.Filter (class IsFilter, StrictlyEquals(..), GreaterThan(..), LessThan(..), by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

import Core.Util.Validation (class IsRefinedType)
import Core.Exception.Exception (inj)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Exception.InvalidNewsletterFilter (InvalidNewsletterFilter(..), InvalidNewsletterFilterRow)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)

data SearchNewslettersProjection

instance
  IsProjection
    SearchNewslettersProjection
    "searchNewsletters"
    "searchNewslettersProjectionWriteOps"
    (SEARCH_NEWSLETTERS_PROJECTION_WRITE_OPS ())
    "searchNewslettersProjectionReadSyncProject"
    { searchNewsletters :: Newsletter }
    { searchNewsletters :: NewsletterIndexNeeds }
    { searchNewsletters :: Record () }
  where
  indexNeeds =
    { searchNewsletters:
        { id: rawIndexOnly
        , scheduledFor: rawIndexOnly
        }
    }

  play = coerce @(SEARCH_NEWSLETTERS_PROJECTION_WRITE_OPS ()) play

type SEARCH_NEWSLETTERS_PROJECTION_WRITE_OPS fx = (searchNewslettersProjectionWriteOps :: ProjectionWriteOps | fx)
type SEARCH_NEWSLETTERS_PROJECTION_READ_SYNC_PROJECT fx = (searchNewslettersProjectionReadSyncProject :: SyncProject | fx)

-- Model 

type NewsletterSortRow =
  ( scheduledFor :: Ɩ
  )

type NewsletterSortCriteria = SortCriteria Newsletter

instance
  IsPair
    NewsletterKey
    Newsletter
    NewsletterRecord
    NewsletterIndexNeeds
    NewsletterSortRow
    "searchNewsletters"
    "searchNewslettersNewsletters"
    "searchNewslettersProjectionReadFind"
    SearchNewslettersProjection
  where
  toKey (Newsletter { id }) = NewsletterKey id
  single = false

newtype Newsletter = Newsletter NewsletterRecord

type NewsletterRecord =
  { id :: NewsletterId
  , scheduledFor :: Instant
  , articles :: Array ArticleId
  }

type NewsletterIndexNeeds =
  { id :: RawIndexOnly NewsletterId
  , scheduledFor :: RawIndexOnly Instant
  }

derive instance Newtype Newsletter _
derive instance Generic Newsletter _
derive instance Eq Newsletter
derive instance Ord Newsletter
derive newtype instance ReadForeign Newsletter
derive newtype instance WriteForeign Newsletter
derive newtype instance Random Newsletter

newtype NewsletterKey = NewsletterKey NewsletterId

derive instance Newtype NewsletterKey _
instance ToAliasedPrimary NewsletterKey where
  toAliasedPrimary (NewsletterKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq NewsletterKey
derive newtype instance Ord NewsletterKey

-- Find

type SEARCH_NEWSLETTERS_PROJECTION_READ_FIND fx = (searchNewslettersProjectionReadFind :: Find Newsletter | fx)
type SEARCH_NEWSLETTERS_PROJECTION_READ fx =
  SEARCH_NEWSLETTERS_PROJECTION_READ_FIND
    + SEARCH_NEWSLETTERS_PROJECTION_READ_SYNC_PROJECT
    + fx

-- Filter

data NewsletterFilter
  = NewsletterIsScheduledFor Instant
  | NewsletterIsScheduledForBetween { start :: Instant, end :: Instant }
  | NewsletterAnd { left :: NewsletterFilter, right :: NewsletterFilter }
  | NewsletterOr { left :: NewsletterFilter, right :: NewsletterFilter }
  | NewsletterNot NewsletterFilter
  | NewsletterTrue
  | NewsletterFalse

derive instance Eq NewsletterFilter
derive instance Ord NewsletterFilter
derive instance Generic NewsletterFilter _

instance Show NewsletterFilter where
  show filter = genericShow filter

instance WriteForeign NewsletterFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign NewsletterFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra NewsletterFilter where
  ff = NewsletterFalse
  tt = NewsletterTrue
  not = NewsletterNot
  implies a b = (NewsletterNot a) || b
  conj left right = NewsletterAnd { left, right }
  disj left right = NewsletterOr { left, right }

instance IsFilter NewsletterFilter Newsletter where
  compile _ (NewsletterIsScheduledFor date) = by @"scheduledFor" StrictlyEquals date

  compile _ (NewsletterIsScheduledForBetween { start: start, end: end }) =
    (by @"scheduledFor" GreaterThan start)
      && (by @"scheduledFor" LessThan end)

  compile e (NewsletterAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (NewsletterOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (NewsletterNot f) = not (compile e f)

  compile _ NewsletterTrue = Base.True
  compile _ NewsletterFalse = Base.False

instance IsRefinedType NewsletterFilter (InvalidNewsletterFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidNewsletterFilter
    Right filter -> η filter

instance Random NewsletterFilter where
  random = NewsletterIsScheduledFor <$> random

findNewsletters
  :: ∀ fx
   . FindOpt NewsletterFilter NewsletterId Newsletter
  -> Run (SEARCH_NEWSLETTERS_PROJECTION_READ + fx) (Page Newsletter)
findNewsletters opt = findMany_ opt { after = opt.after <#> NewsletterKey ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (SEARCH_NEWSLETTERS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  NewsletterScheduled payload -> onNewsletterScheduled payload
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
  ArticleWritten _ -> ηι
  ArticleQuoted _ -> ηι
  NewsTopicAdded _ -> ηι
  NewsTopicRemoved _ -> ηι
  ArticleAddedToNewsRelatedWhitelist _ -> ηι
  ArticleRemovedFromNewsRelatedWhitelist _ -> ηι
  ArticleAddedToNewsRelatedBlacklist _ -> ηι
  ArticleRemovedFromNewsRelatedBlacklist _ -> ηι
  ArticleRead _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

onNewsletterScheduled :: ∀ fx. NewsletterScheduled.Payload -> Run (SEARCH_NEWSLETTERS_PROJECTION_WRITE_OPS fx) Ɩ
onNewsletterScheduled { id, scheduledFor, articles } = add $ Newsletter { id, scheduledFor, articles }


