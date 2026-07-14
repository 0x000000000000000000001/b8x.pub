module Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Finder.Filter (class IsFilter, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, get, patch)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Mod.Time.Instant (Instant)
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.MagazineIssueReferenced.Payload as MagazineIssueReferenced
import Core.Event.MagazineIssueDereferenced.Payload as MagazineIssueDereferenced
import Core.Mod.Article.MagazineIssue.MagazineIssue as ArticleMagazineIssue
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)
import Core.Util.Validation (class IsRefinedType)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Exception.InvalidMagazineIssueFilter (InvalidMagazineIssueFilter(..), InvalidMagazineIssueFilterRow)
import Data.Either (Either(..))
import Core.Exception.Exception (inj)

data ListMagazineIssuesProjection

instance
  IsProjection
    ListMagazineIssuesProjection
    "listMagazineIssues"
    "listMagazineIssuesProjectionWriteOps"
    (LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS ())
    "listMagazineIssuesProjectionReadSyncProject"
    { listMagazineIssues :: MagazineIssue }
    { listMagazineIssues :: MagazineIssueIndexNeeds }
    { listMagazineIssues :: Record MagazineIssueSortRow }
  where
  indexNeeds =
    { listMagazineIssues:
        { id: rawIndexOnly
        , number: rawIndexOnly
        , slug: rawIndexOnly
        , seo:
            { updatedAt: rawIndexOnly
            }
        }
    }

  play = coerce @(LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS ()) play

type LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx = (listMagazineIssuesProjectionWriteOps :: ProjectionWriteOps | fx)
type LIST_MAGAZINE_ISSUES_PROJECTION_READ_SYNC_PROJECT fx = (listMagazineIssuesProjectionReadSyncProject :: SyncProject | fx)

type LIST_MAGAZINE_ISSUES_PROJECTION_READ_FIND fx =
  LIST_MAGAZINE_ISSUES_LIST_MAGAZINE_ISSUES_PROJECTION_READ_FIND
    + fx

-- Model 

---- MagazineIssue 

type MagazineIssueSortRow =
  ( id :: Ɩ
  , number :: Ɩ
  , slug :: Ɩ
  , "seo.updatedAt" :: Ɩ
  )

type MagazineIssueSortCriteria = SortCriteria MagazineIssue

instance IsPair MagazineIssueKey MagazineIssue MagazineIssueRecord MagazineIssueIndexNeeds MagazineIssueSortRow "listMagazineIssues" "listMagazineIssues" "listMagazineIssuesListMagazineIssuesProjectionReadFind" ListMagazineIssuesProjection where
  toKey (MagazineIssue { id }) = MagazineIssueKey id

  single = false

newtype MagazineIssue = MagazineIssue MagazineIssueRecord

type MagazineIssueRecord =
  { id :: MagazineIssueId
  , number :: Int
  , slug :: Slug
  , seo ::
      { updatedAt :: Instant
      }
  }

type MagazineIssueIndexNeeds =
  { id :: RawIndexOnly MagazineIssueId
  , number :: RawIndexOnly Int
  , slug :: RawIndexOnly Slug
  , seo ::
      { updatedAt :: RawIndexOnly Instant
      }
  }

derive instance Newtype MagazineIssue _
derive instance Generic MagazineIssue _
derive instance Eq MagazineIssue
derive instance Ord MagazineIssue
derive newtype instance ReadForeign MagazineIssue
derive newtype instance WriteForeign MagazineIssue

instance Random MagazineIssue where
  random = do
    id <- random
    number <- random
    slug <- random
    updatedAt <- random

    η $ MagazineIssue
      { id
      , number
      , slug
      , seo: { updatedAt }
      }

newtype MagazineIssueKey = MagazineIssueKey MagazineIssueId

derive instance Newtype MagazineIssueKey _
derive newtype instance Eq MagazineIssueKey
derive newtype instance Ord MagazineIssueKey

instance ToAliasedPrimary MagazineIssueKey where
  toAliasedPrimary (MagazineIssueKey id) = { primary: toString id, aliases: [] }

-- Find

type LIST_MAGAZINE_ISSUES_LIST_MAGAZINE_ISSUES_PROJECTION_READ_FIND fx = (listMagazineIssuesListMagazineIssuesProjectionReadFind :: Find MagazineIssue | fx)
type LIST_MAGAZINE_ISSUES_LIST_MAGAZINE_ISSUES_PROJECTION_READ fx =
  LIST_MAGAZINE_ISSUES_LIST_MAGAZINE_ISSUES_PROJECTION_READ_FIND
    + LIST_MAGAZINE_ISSUES_PROJECTION_READ_SYNC_PROJECT
    + fx

-- Filter

data MagazineIssueFilter
  = MagazineIssueAnd { left :: MagazineIssueFilter, right :: MagazineIssueFilter }
  | MagazineIssueOr { left :: MagazineIssueFilter, right :: MagazineIssueFilter }
  | MagazineIssueNot MagazineIssueFilter
  | MagazineIssueTrue
  | MagazineIssueFalse

derive instance Eq MagazineIssueFilter
derive instance Ord MagazineIssueFilter
derive instance Generic MagazineIssueFilter _

instance Show MagazineIssueFilter where
  show filter = genericShow filter

instance WriteForeign MagazineIssueFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign MagazineIssueFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra MagazineIssueFilter where
  ff = MagazineIssueFalse
  tt = MagazineIssueTrue
  not = MagazineIssueNot
  implies a b = (MagazineIssueNot a) || b
  conj left right = MagazineIssueAnd { left, right }
  disj left right = MagazineIssueOr { left, right }

instance IsFilter MagazineIssueFilter MagazineIssue where
  compile e (MagazineIssueAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (MagazineIssueOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (MagazineIssueNot f) = not (compile e f)

  compile _ MagazineIssueTrue = Base.True
  compile _ MagazineIssueFalse = Base.False

instance IsRefinedType MagazineIssueFilter (InvalidMagazineIssueFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidMagazineIssueFilter
    Right filter -> η filter

instance Random MagazineIssueFilter where
  random = η MagazineIssueTrue

findMagazineIssues
  :: ∀ fx
   . FindOpt MagazineIssueFilter MagazineIssueId MagazineIssue
  -> Run (LIST_MAGAZINE_ISSUES_LIST_MAGAZINE_ISSUES_PROJECTION_READ + fx) (Page MagazineIssue)
findMagazineIssues opt = findMany_ opt { after = opt.after <#> MagazineIssueKey ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
play { event, at } = case event of
  MagazineIssueReferenced payload -> onMagazineIssueReferenced at payload
  MagazineIssueDereferenced payload -> onMagazineIssueDereferenced payload
  ArticleWritten payload -> onArticleWritten at payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
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

onMagazineIssueReferenced :: ∀ fx. Instant -> MagazineIssueReferenced.Payload -> Run (LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueReferenced at { id, number, slug } = do
  mIssue <- get (MagazineIssueKey id)
  case mIssue of
    Nothing -> add $ MagazineIssue { id, number, slug, seo: { updatedAt: at } }
    Just _ -> patch (MagazineIssueKey id) \(MagazineIssue r) -> MagazineIssue (r { number = number, slug = slug, seo = { updatedAt: at } })

onMagazineIssueDereferenced :: ∀ fx. MagazineIssueDereferenced.Payload -> Run (LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueDereferenced { issue } = delete (MagazineIssueKey issue)

onArticleWritten :: ∀ fx. Instant -> ArticleWritten.Payload -> Run (LIST_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten at { magazineIssue } = case magazineIssue of
  Just (ArticleMagazineIssue.MagazineIssue mi) -> patch (MagazineIssueKey mi.issue) \(MagazineIssue r) -> MagazineIssue (r { seo = { updatedAt: at } })
  Nothing -> ηι


