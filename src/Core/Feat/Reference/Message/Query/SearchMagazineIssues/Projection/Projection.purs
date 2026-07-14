module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Projection where

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Proem hiding (add)
import Control.Monad.Except as Control.Monad.Except

import Core.Event.MagazineIssueDereferenced.Payload as MagazineIssueDereferenced
import Core.Event.MagazineIssueReferenced.Payload as MagazineIssueReferenced
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.Time.Instant (Instant)
import Core.Mod.Image.Image (Image)
import Core.Mod.Article.MagazineIssue.MagazineIssue as ArticleMagazineIssue
import Core.Mod.MagazineIssue.Id.Id (MagazineIssueId)
import Core.Mod.MagazineIssue.Name.Name as MagazineIssueName
import Core.Mod.MagazineIssue.Number.Number (IssueNumber)
import Core.Mod.MagazineIssue.ReleasedAt.ReleasedAt (ReleasedAt)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Exception.InvalidMagazineIssueFilter (InvalidMagazineIssueFilter(..), InvalidMagazineIssueFilterRow)
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Finder.Filter (class IsFilter, EqualsUpToNormalization(..), Matches(..), StrictlyEquals(..), Weight, by, compile)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Sort (SortCriteria)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete, patch)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, RawIndexOnly, everyTextIndexesWithWeightA, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)

data SearchMagazineIssuesProjection

instance
  IsProjection
    SearchMagazineIssuesProjection
    "searchMagazineIssues"
    "searchMagazineIssuesProjectionWriteOps"
    (SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS ())
    "searchMagazineIssuesProjectionReadSyncProject"
    { searchMagazineIssues :: MagazineIssue
    }
    { searchMagazineIssues :: MagazineIssueIndexNeeds
    }
    { searchMagazineIssues :: Record MagazineIssueSortRow
    }
  where
  indexNeeds =
    { searchMagazineIssues:
        { id: rawIndexOnly
        , name: everyTextIndexesWithWeightA
        , legacyId: rawIndexOnly
        , special: rawIndexOnly
        , complement: rawIndexOnly
        , number: rawIndexOnly
        , slug: rawIndexOnly
        , seo:
            { updatedAt: rawIndexOnly
            }
        }
    }

  play = coerce @(SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS ()) play

type SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx = (searchMagazineIssuesProjectionWriteOps :: ProjectionWriteOps | fx)
type SEARCH_MAGAZINE_ISSUES_PROJECTION_READ_SYNC_PROJECT fx = (searchMagazineIssuesProjectionReadSyncProject :: SyncProject | fx)

type SEARCH_MAGAZINE_ISSUES_PROJECTION_READ_FIND fx =
  SEARCH_MAGAZINE_ISSUES_MAGAZINE_ISSUE_PROJECTION_READ_FIND
    + fx

-- Model 

---- MagazineIssue 

type MagazineIssueSortRow =
  ( name :: Ɩ
  , number :: Ɩ
  , "seo.updatedAt" :: Ɩ
  )

type MagazineIssueSortCriteria = SortCriteria MagazineIssue

instance IsPair MagazineIssueKey MagazineIssue MagazineIssueRecord MagazineIssueIndexNeeds MagazineIssueSortRow "searchMagazineIssues" "searchMagazineIssuesMagazineIssues" "searchMagazineIssuesMagazineIssueProjectionReadFind" SearchMagazineIssuesProjection where
  toKey (MagazineIssue { id }) = MagazineIssueKey id

  single = false

newtype MagazineIssue = MagazineIssue MagazineIssueRecord

type MagazineIssueRecord =
  { id :: MagazineIssueId
  , name :: MagazineIssueName.Name
  , legacyId :: Maybe Int
  , special :: Boolean
  , complement :: Boolean
  , number :: IssueNumber
  , cover :: Maybe Image
  , releasedAt :: Maybe ReleasedAt
  , slug :: Slug
  , seo ::
      { updatedAt :: Instant
      }
  }

type MagazineIssueIndexNeeds =
  { id :: RawIndexOnly MagazineIssueId
  , name :: EveryTextIndexesWithWeightA MagazineIssueName.Name
  , legacyId :: RawIndexOnly (Maybe Int)
  , special :: RawIndexOnly Boolean
  , complement :: RawIndexOnly Boolean
  , number :: RawIndexOnly IssueNumber
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
    name <- random
    legacyId <- random
    special <- random
    complement <- random
    number <- random
    cover <- random
    releasedAt <- random
    slug <- random
    updatedAt <- random

    η $ MagazineIssue
      { id
      , name
      , legacyId
      , special
      , complement
      , number
      , cover
      , releasedAt
      , slug
      , seo: { updatedAt }
      }

newtype MagazineIssueKey = MagazineIssueKey MagazineIssueId

derive instance Newtype MagazineIssueKey _
instance ToAliasedPrimary MagazineIssueKey where
  toAliasedPrimary (MagazineIssueKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq MagazineIssueKey
derive newtype instance Ord MagazineIssueKey

-- Find

type SEARCH_MAGAZINE_ISSUES_MAGAZINE_ISSUE_PROJECTION_READ_FIND fx = (searchMagazineIssuesMagazineIssueProjectionReadFind :: Find MagazineIssue | fx)
type SEARCH_MAGAZINE_ISSUES_MAGAZINE_ISSUE_PROJECTION_READ fx =
  SEARCH_MAGAZINE_ISSUES_MAGAZINE_ISSUE_PROJECTION_READ_FIND
    + SEARCH_MAGAZINE_ISSUES_PROJECTION_READ_SYNC_PROJECT
    + fx

-- Filter

data MagazineIssueFilter
  = MagazineIssueHasId MagazineIssueId
  | MagazineIssueHasName { name :: MagazineIssueName.Name, weight :: Weight }
  | MagazineIssueHasExactName MagazineIssueName.Name
  | MagazineIssueHasLegacyId Int
  | MagazineIssueHasNumber IssueNumber
  | MagazineIssueIsSpecial Boolean
  | MagazineIssueIsComplement Boolean
  | MagazineIssueHasSlug Slug
  | MagazineIssueAnd { left :: MagazineIssueFilter, right :: MagazineIssueFilter }
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
  compile _ (MagazineIssueHasId id) = by @"id" StrictlyEquals id
  compile e (MagazineIssueHasName { name: name, weight: w }) = by @"name" (Matches { weight: w, expectation: e }) name
  compile _ (MagazineIssueHasExactName name) = by @"name" EqualsUpToNormalization name
  compile _ (MagazineIssueHasLegacyId legacyId) = by @"legacyId" StrictlyEquals (Just legacyId)
  compile _ (MagazineIssueHasNumber number) = by @"number" StrictlyEquals number
  compile _ (MagazineIssueIsSpecial special) = by @"special" StrictlyEquals special
  compile _ (MagazineIssueIsComplement complement) = by @"complement" StrictlyEquals complement
  compile _ (MagazineIssueHasSlug slug) = by @"slug" StrictlyEquals slug

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
  random = MagazineIssueHasId <$> random

findMagazineIssues
  :: ∀ fx
   . FindOpt MagazineIssueFilter MagazineIssueId MagazineIssue
  -> Run (SEARCH_MAGAZINE_ISSUES_MAGAZINE_ISSUE_PROJECTION_READ + fx) (Page MagazineIssue)
findMagazineIssues opt = findMany_ opt { after = opt.after <#> MagazineIssueKey ▷ persistenceKeyFromKey }

-- Play 

play :: ∀ fx. LoadedEvent -> Run (SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
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

onMagazineIssueReferenced :: ∀ fx. Instant -> MagazineIssueReferenced.Payload -> Run (SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueReferenced at { id, name, legacyId, special, complement, number, cover, releasedAt, slug } = add $ MagazineIssue { id, name, legacyId, special, complement, number, cover, releasedAt, slug, seo: { updatedAt: at } }

onMagazineIssueDereferenced :: ∀ fx. MagazineIssueDereferenced.Payload -> Run (SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
onMagazineIssueDereferenced { issue } = delete $ MagazineIssueKey issue

onArticleWritten :: ∀ fx. Instant -> ArticleWritten.Payload -> Run (SEARCH_MAGAZINE_ISSUES_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten at { magazineIssue } = case magazineIssue of
  Just (ArticleMagazineIssue.MagazineIssue mi) -> patch (MagazineIssueKey mi.issue) \(MagazineIssue r) -> MagazineIssue (r { seo = { updatedAt: at } })
  Nothing -> ηι


