module Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Projection where

import Proem hiding (add)

import Yoga.JSON.Generics (genericWriteForeignTaggedSum, genericReadForeignTaggedSum)
import Yoga.JSON.Generics.TaggedSumRep (defaultOptions)
import Control.Monad.Except as Control.Monad.Except
import Core.Event.NewsTopicAdded.Payload as NewsTopicAdded
import Core.Event.NewsTopicRemoved.Payload as NewsTopicRemoved
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Exception.Exception (inj)
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Core.Mod.NewsTopic.SearchInput.SearchInput (SearchInput)
import Core.Feat.Review.Message.Query.SearchNewsTopics.Exception.InvalidNewsTopicFilter (InvalidNewsTopicFilter(..), InvalidNewsTopicFilterRow)
import Core.Mod.Projection.Finder.Filter (class IsFilter, EqualsUpToNormalization(..), StrictlyEquals(..), by, compile, Matches(..), Weight)
import Core.Mod.Projection.Finder.Filter as Base
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, Page, findMany_)
import Core.Mod.Projection.Pair (class IsPair, class ToPrimary, class ToAliases, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete)
import Core.Mod.Projection.SearchIndex (EveryTextIndexesWithWeightA, RawIndexOnly, everyTextIndexesWithWeightA, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Core.Util.Validation (class IsRefinedType)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (toString)

data SearchNewsTopicsProjection

instance
  IsProjection
    SearchNewsTopicsProjection
    "searchNewsTopics"
    "searchNewsTopicsProjectionWriteOps"
    (SEARCH_NEWS_TOPICS_PROJECTION_WRITE_OPS ())
    "searchNewsTopicsProjectionReadSyncProject"
    { newsTopic :: NewsTopic }
    { newsTopic :: NewsTopicIndexNeeds }
    { newsTopic :: Record () }
  where
  indexNeeds =
    { newsTopic:
        { id: rawIndexOnly
        , searchInput: everyTextIndexesWithWeightA
        }
    }

  play = coerce @(SEARCH_NEWS_TOPICS_PROJECTION_WRITE_OPS ()) play

type SEARCH_NEWS_TOPICS_PROJECTION_WRITE_OPS fx = (searchNewsTopicsProjectionWriteOps :: ProjectionWriteOps | fx)
type SEARCH_NEWS_TOPICS_PROJECTION_READ_SYNC_PROJECT fx = (searchNewsTopicsProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance IsPair NewsTopicKey NewsTopic NewsTopicRecord NewsTopicIndexNeeds () "newsTopic" "newsTopics" "searchNewsTopicsProjectionReadFind" SearchNewsTopicsProjection where
  toKey (NewsTopic { id }) = NewsTopicKey id

  single = false

newtype NewsTopic = NewsTopic NewsTopicRecord

instance ToAliases NewsTopic where
  toAliases _ = []

type NewsTopicRecord =
  { id :: NewsTopicId
  , searchInput :: SearchInput
  }

type NewsTopicIndexNeeds =
  { id :: RawIndexOnly NewsTopicId
  , searchInput :: EveryTextIndexesWithWeightA SearchInput
  }

derive instance Newtype NewsTopic _
derive instance Generic NewsTopic _
derive instance Eq NewsTopic
derive instance Ord NewsTopic
derive newtype instance ReadForeign NewsTopic
derive newtype instance WriteForeign NewsTopic
derive newtype instance Random NewsTopic
derive newtype instance Show NewsTopic

newtype NewsTopicKey = NewsTopicKey NewsTopicId

derive instance Newtype NewsTopicKey _
instance ToPrimary NewsTopicKey where
  toPrimary (NewsTopicKey id) = toString id

derive newtype instance Eq NewsTopicKey
derive newtype instance Ord NewsTopicKey

-- Filter

data NewsTopicFilter
  = NewsTopicHasId NewsTopicId
  | NewsTopicHasSearchInput { searchInput :: SearchInput, weight :: Weight }
  | NewsTopicHasExactSearchInput SearchInput
  | NewsTopicAnd { left :: NewsTopicFilter, right :: NewsTopicFilter }
  | NewsTopicOr { left :: NewsTopicFilter, right :: NewsTopicFilter }
  | NewsTopicNot NewsTopicFilter
  | NewsTopicTrue
  | NewsTopicFalse

derive instance Eq NewsTopicFilter
derive instance Ord NewsTopicFilter
derive instance Generic NewsTopicFilter _

instance Show NewsTopicFilter where
  show filter = genericShow filter

instance WriteForeign NewsTopicFilter where
  writeImpl filter = (genericWriteForeignTaggedSum defaultOptions) filter

instance ReadForeign NewsTopicFilter where
  readImpl json = (genericReadForeignTaggedSum defaultOptions) json

instance HeytingAlgebra NewsTopicFilter where
  ff = NewsTopicFalse
  tt = NewsTopicTrue
  not = NewsTopicNot
  implies a b = (NewsTopicNot a) || b
  conj left right = NewsTopicAnd { left, right }
  disj left right = NewsTopicOr { left, right }

instance IsFilter NewsTopicFilter NewsTopic where
  compile _ (NewsTopicHasId id) = by @"id" StrictlyEquals id
  compile e (NewsTopicHasSearchInput { searchInput, weight: w }) = by @"searchInput" (Matches { weight: w, expectation: e }) searchInput
  compile _ (NewsTopicHasExactSearchInput searchInput) = by @"searchInput" EqualsUpToNormalization searchInput

  compile e (NewsTopicAnd { left: f1, right: f2 }) =
    (compile e f1)
      && (compile e f2)

  compile e (NewsTopicOr { left: f1, right: f2 }) =
    (compile e f1)
      || (compile e f2)

  compile e (NewsTopicNot f) = not (compile e f)

  compile _ NewsTopicTrue = Base.True
  compile _ NewsTopicFalse = Base.False

instance IsRefinedType NewsTopicFilter (InvalidNewsTopicFilterRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Left $ inj InvalidNewsTopicFilter
    Right filter -> η filter

instance Random NewsTopicFilter where
  random = NewsTopicHasId <$> random

-- Find

type SEARCH_NEWS_TOPICS_PROJECTION_READ_FIND fx = (searchNewsTopicsProjectionReadFind :: Find NewsTopic | fx)
type SEARCH_NEWS_TOPICS_PROJECTION_READ fx =
  SEARCH_NEWS_TOPICS_PROJECTION_READ_FIND
    + SEARCH_NEWS_TOPICS_PROJECTION_READ_SYNC_PROJECT
    + fx

findNewsTopics
  :: ∀ fx
   . FindOpt NewsTopicFilter NewsTopicId NewsTopic
  -> Run (SEARCH_NEWS_TOPICS_PROJECTION_READ + fx) (Page NewsTopic)
findNewsTopics opt@{ after } = findMany_ opt { after = after <#> NewsTopicKey ▷ persistenceKeyFromKey }

-- Play

play :: ∀ fx. LoadedEvent -> Run (SEARCH_NEWS_TOPICS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  NewsTopicAdded payload -> onNewsTopicAdded payload
  NewsTopicRemoved payload -> onNewsTopicRemoved payload
  AuthorReferenced _ -> ηι
  AuthorDereferenced _ -> ηι
  BookReferenced _ -> ηι
  BookDereferenced _ -> ηι
  BookEditorCorrected _ -> ηι
  BookCoverCorrected _ -> ηι
  ArticleTitleCorrected _ -> ηι
  ArticleContentCorrected _ -> ηι
  ArticleLeadCorrected _ -> ηι
  AuthorBiographyCorrected _ -> ηι
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
  ArticleAddedToNewsRelatedWhitelist _ -> ηι
  ArticleRemovedFromNewsRelatedWhitelist _ -> ηι
  ArticleAddedToNewsRelatedBlacklist _ -> ηι
  ArticleRemovedFromNewsRelatedBlacklist _ -> ηι
  ArticleRead _ -> ηι
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

---- Listeners

onNewsTopicAdded :: ∀ fx. NewsTopicAdded.Payload -> Run (SEARCH_NEWS_TOPICS_PROJECTION_WRITE_OPS fx) Ɩ
onNewsTopicAdded { id, searchInput } = add $ NewsTopic { id, searchInput }

onNewsTopicRemoved :: ∀ fx. NewsTopicRemoved.Payload -> Run (SEARCH_NEWS_TOPICS_PROJECTION_WRITE_OPS fx) Ɩ
onNewsTopicRemoved { newsTopic } = delete $ NewsTopicKey newsTopic
