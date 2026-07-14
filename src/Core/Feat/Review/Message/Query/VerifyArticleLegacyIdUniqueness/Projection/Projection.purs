module Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Projection.Projection where

import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Projection.Finder.Filter (StrictlyEquals(..))
import Core.Mod.Projection.Finder.Finder (Find, findOneBy)
import Core.Mod.Projection.Pair (class IsPair, class ToAliasedPrimary)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..), maybe)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Proem (class Eq, class Ord, class Show, Ɩ, ηι, ($), (<<<))
import Run (Run)
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.String.ToString (toString)
import Yoga.JSON (class ReadForeign, class WriteForeign)

data VerifyArticleLegacyIdUniquenessProjection

instance
  IsProjection
    VerifyArticleLegacyIdUniquenessProjection
    "verifyArticleLegacyIdUniqueness"
    "verifyArticleLegacyIdUniquenessProjectionWriteOps"
    (VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_OPS ())
    "verifyArticleLegacyIdUniquenessProjectionReadSyncProject"
    { verifyArticleLegacyIdUniqueness :: Article }
    { verifyArticleLegacyIdUniqueness :: ArticleIndexNeeds }
    { verifyArticleLegacyIdUniqueness :: Record () }
  where
  indexNeeds =
    { verifyArticleLegacyIdUniqueness:
        { id: rawIndexOnly
        , legacyId: rawIndexOnly
        }
    }

  play = coerce @(VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_OPS ()) play

type VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_OPS fx = (verifyArticleLegacyIdUniquenessProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT fx = (verifyArticleLegacyIdUniquenessProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    ArticleKey
    Article
    ArticleRecord
    ArticleIndexNeeds
    ()
    "verifyArticleLegacyIdUniqueness"
    "verifyArticleLegacyIdUniquenessArticles"
    "verifyArticleLegacyIdUniquenessProjectionReadFind"
    VerifyArticleLegacyIdUniquenessProjection
  where
  toKey (Article { id }) = ArticleKey { id: Just id, slug: Nothing }
  single = false

newtype Article = Article ArticleRecord

type ArticleRecord =
  { id :: ArticleId
  , legacyId :: Maybe Int
  }

type ArticleIndexNeeds =
  { id :: RawIndexOnly ArticleId
  , legacyId :: RawIndexOnly (Maybe Int)
  }

derive instance Newtype Article _
derive instance Generic Article _
derive instance Eq Article
derive instance Ord Article
derive newtype instance ReadForeign Article
derive newtype instance WriteForeign Article
derive newtype instance Random Article

instance Show Article where
  show = genericShow

newtype ArticleKey = ArticleKey { id :: Maybe ArticleId, slug :: Maybe Slug }

derive instance Newtype ArticleKey _
instance ToAliasedPrimary ArticleKey where
  toAliasedPrimary (ArticleKey k) = { primary: maybe "" toString k.id, aliases: maybe [] (Array.singleton <<< toString) k.slug }

derive instance Eq ArticleKey
derive instance Ord ArticleKey
derive instance Generic ArticleKey _

instance Show ArticleKey where
  show = genericShow

-- Find

type VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_READ_FIND fx = (verifyArticleLegacyIdUniquenessProjectionReadFind :: Find Article | fx)
type VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_READ fx =
  VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_READ_FIND
    + VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticleByLegacyId :: ∀ fx. Int -> Run (VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_READ + fx) (Maybe Article)
findArticleByLegacyId legacyId = findOneBy @Article @"legacyId" StrictlyEquals (Just legacyId)

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  ArticleWritten payload -> onArticleWritten payload
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

onArticleWritten :: ∀ fx. ArticleWritten.Payload -> Run (VERIFY_ARTICLE_LEGACY_ID_UNIQUENESS_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten { id, legacyId } = add $ Article { id, legacyId }
