module Core.Feat.Review.Message.Command.WriteArticle.Projection.Projection where

import Proem hiding (add)

import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Event.ArticleWritten.Payload as ArticleWritten
import Core.Event.Event (Event(..), LoadedEvent)
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Article.Slug.Slug (Slug)
import Core.Mod.Projection.Finder.Filter (StrictlyEquals(..))
import Core.Mod.Projection.Finder.Finder (Find, findOneBy)
import Core.Mod.Projection.Pair (class IsPair, class ToPrimary, class ToAliases)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete)
import Core.Mod.Projection.SearchIndex (RawIndexOnly, rawIndexOnly)
import Core.Mod.Projection.SyncProject (SyncProject)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Run (Run)
import Type.Row (type (+))
import Util.Type.String.ToString (toString)

data WriteArticleProjection

instance
  IsProjection
    WriteArticleProjection
    "writeArticle"
    "writeArticleProjectionWriteOps"
    (WRITE_ARTICLE_PROJECTION_WRITE_OPS ())
    "writeArticleProjectionReadSyncProject"
    { article :: Article }
    { article :: ArticleIndexNeeds }
    { article :: Record () }
  where
  indexNeeds =
    { article:
        { id: rawIndexOnly
        , slug: rawIndexOnly
        }
    }

  play = coerce @(WRITE_ARTICLE_PROJECTION_WRITE_OPS ()) play

type WRITE_ARTICLE_PROJECTION_WRITE_OPS fx = (writeArticleProjectionWriteOps :: ProjectionWriteOps | fx)
type WRITE_ARTICLE_PROJECTION_READ_SYNC_PROJECT fx = (writeArticleProjectionReadSyncProject :: SyncProject | fx)

-- Model

instance
  IsPair
    ArticleKey
    Article
    ArticleRecord
    ArticleIndexNeeds
    ()
    "article"
    "articles"
    "writeArticleProjectionReadFind"
    WriteArticleProjection
  where
  toKey (Article { id }) = ArticleKey id

  single = false

newtype Article = Article ArticleRecord

instance ToAliases Article where
  toAliases (Article { slug }) = [ toString slug ]

type ArticleRecord =
  { id :: ArticleId
  , slug :: Slug
  }

type ArticleIndexNeeds =
  { id :: RawIndexOnly ArticleId
  , slug :: RawIndexOnly Slug
  }

derive instance Newtype Article _
derive instance Generic Article _
derive instance Eq Article
derive instance Ord Article
derive newtype instance ReadForeign Article
derive newtype instance WriteForeign Article

instance Show Article where
  show = genericShow

newtype ArticleKey = ArticleKey ArticleId

derive instance Newtype ArticleKey _
instance ToPrimary ArticleKey where
  toPrimary (ArticleKey id) = toString id

derive instance Eq ArticleKey
derive instance Ord ArticleKey
derive instance Generic ArticleKey _

instance Show ArticleKey where
  show = genericShow

-- Find

type WRITE_ARTICLE_PROJECTION_READ_FIND fx = (writeArticleProjectionReadFind :: Find Article | fx)
type WRITE_ARTICLE_PROJECTION_READ fx =
  WRITE_ARTICLE_PROJECTION_READ_FIND
    + WRITE_ARTICLE_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticleBySlug
  :: ∀ fx
   . Slug
  -> Run (WRITE_ARTICLE_PROJECTION_READ + fx) (Maybe Article)
findArticleBySlug slug = findOneBy @Article @"slug" StrictlyEquals slug

-- Play

play :: ∀ fx. LoadedEvent -> Run (WRITE_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  ArticleWritten payload -> onArticleWritten payload
  ArticleDiscarded payload -> onArticleDiscarded payload
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

onArticleWritten :: ∀ fx. ArticleWritten.Payload -> Run (WRITE_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleWritten { id, slug } = add $ Article { id, slug }

onArticleDiscarded :: ∀ fx. ArticleDiscarded.Payload -> Run (WRITE_ARTICLE_PROJECTION_WRITE_OPS fx) Ɩ
onArticleDiscarded { article } = delete (ArticleKey article)
