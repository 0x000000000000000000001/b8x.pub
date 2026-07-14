module Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Projection.Projection where

import Proem hiding (add)

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.NewsTopicAdded.Payload as NewsTopicAdded
import Core.Event.NewsTopicRemoved.Payload as NewsTopicRemoved
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Core.Mod.Projection.Finder.Finder (Find, findAll)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, delete, coerce)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.String.ToString (toString)

data VerifyNewsTopicLimitProjection

instance
  IsProjection
    VerifyNewsTopicLimitProjection
    "verifyNewsTopicLimit"
    "verifyNewsTopicLimitProjectionWriteOps"
    (VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_OPS ())
    "verifyNewsTopicLimitProjectionReadSyncProject"
    { verifyNewsTopicLimit :: NewsTopic }
    { verifyNewsTopicLimit :: NewsTopicIndexNeeds }
    { verifyNewsTopicLimit :: Record () }
  where
  indexNeeds =
    { verifyNewsTopicLimit:
        { id: rawIndexOnly
        }
    }

  play = coerce @(VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_OPS ()) play

type VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_OPS fx = (verifyNewsTopicLimitProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_READ_SYNC_PROJECT fx = (verifyNewsTopicLimitProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    NewsTopicKey
    NewsTopic
    NewsTopicRecord
    NewsTopicIndexNeeds
    ()
    "verifyNewsTopicLimit"
    "verifyNewsTopicLimitNewsTopics"
    "verifyNewsTopicLimitProjectionReadFind"
    VerifyNewsTopicLimitProjection
  where
  toKey (NewsTopic { id }) = NewsTopicKey id
  single = false

newtype NewsTopic = NewsTopic NewsTopicRecord

type NewsTopicRecord =
  { id :: NewsTopicId
  }

type NewsTopicIndexNeeds =
  { id :: RawIndexOnly NewsTopicId
  }

derive instance Newtype NewsTopic _
derive instance Generic NewsTopic _
derive instance Eq NewsTopic
derive instance Ord NewsTopic
derive newtype instance ReadForeign NewsTopic
derive newtype instance WriteForeign NewsTopic
derive newtype instance Random NewsTopic

instance Show NewsTopic where
  show = genericShow

newtype NewsTopicKey = NewsTopicKey NewsTopicId

derive instance Newtype NewsTopicKey _
instance ToAliasedPrimary NewsTopicKey where
  toAliasedPrimary (NewsTopicKey id) = { primary: toString id, aliases: [] }
derive newtype instance Eq NewsTopicKey
derive newtype instance Ord NewsTopicKey
derive instance Generic NewsTopicKey _

instance Show NewsTopicKey where
  show = genericShow

-- Find

type VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_READ_FIND fx = (verifyNewsTopicLimitProjectionReadFind :: Find NewsTopic | fx)
type VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_READ fx =
  VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_READ_FIND
    + VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_READ_SYNC_PROJECT
    + fx

findAllNewsTopics :: ∀ fx. Run (VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_READ + fx) (Array NewsTopic)
findAllNewsTopics = findAll

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  NewsTopicAdded payload -> onNewsTopicAdded payload
  NewsTopicRemoved payload -> onNewsTopicRemoved payload
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
  ArticleAddedToNewsRelatedWhitelist _ -> ηι
  ArticleRemovedFromNewsRelatedWhitelist _ -> ηι
  ArticleAddedToNewsRelatedBlacklist _ -> ηι
  ArticleRemovedFromNewsRelatedBlacklist _ -> ηι
  ArticleRead _ -> ηι
  NewsletterScheduled _ -> ηι
  MagazineCustomSectionAdded _ -> ηι
  UserDonated _ -> ηι

onNewsTopicAdded :: ∀ fx. NewsTopicAdded.Payload -> Run (VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_OPS fx) Ɩ
onNewsTopicAdded { id } = add $ NewsTopic { id }

onNewsTopicRemoved :: ∀ fx. NewsTopicRemoved.Payload -> Run (VERIFY_NEWS_TOPIC_MAX_LIMIT_PROJECTION_WRITE_OPS fx) Ɩ
onNewsTopicRemoved { newsTopic } = delete $ NewsTopicKey newsTopic
