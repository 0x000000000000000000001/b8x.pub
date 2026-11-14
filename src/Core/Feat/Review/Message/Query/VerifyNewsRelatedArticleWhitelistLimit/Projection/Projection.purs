module Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Projection.Projection where

import Proem (class Eq, class Ord, class Show, Ɩ, ηι, ($), (<#>), (▷))

import Core.Event.Event (Event(..), LoadedEvent)
import Core.Event.ArticleDiscarded.Payload as ArticleDiscarded
import Core.Event.ArticleAddedToNewsRelatedWhitelist.Payload as ArticleAddedToNewsRelatedWhitelist
import Core.Event.ArticleRemovedFromNewsRelatedWhitelist.Payload as ArticleRemovedFromNewsRelatedWhitelist
import Core.Mod.Article.Id.Id (ArticleId)
import Core.Mod.Projection.Finder.Finder (Find, FindOpt, findMany_)
import Core.Mod.Projection.Finder.Filter (class IsFilter)
import Core.Mod.Projection.Pair (class IsPair, class ToPrimary, class ToAliases, persistenceKeyFromKey)
import Partial.Unsafe (unsafeCrashWith)
import Core.Mod.Projection.Projection (class IsProjection, ProjectionWriteOps, add, coerce, delete)
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

data VerifyNewsRelatedArticleWhitelistLimitProjection

instance
  IsProjection
    VerifyNewsRelatedArticleWhitelistLimitProjection
    "verifyNewsRelatedArticleWhitelistLimit"
    "verifyNewsRelatedArticleWhitelistLimitProjectionWriteOps"
    (VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_OPS ())
    "verifyNewsRelatedArticleWhitelistLimitProjectionReadSyncProject"
    { article :: Article }
    { article :: ArticleIndexNeeds }
    { article :: Record () }
  where
  indexNeeds =
    { article:
        { id: rawIndexOnly
        }
    }

  play = coerce @(VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_OPS ()) play

type VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_OPS fx = (verifyNewsRelatedArticleWhitelistLimitProjectionWriteOps :: ProjectionWriteOps | fx)
type VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_READ_SYNC_PROJECT fx = (verifyNewsRelatedArticleWhitelistLimitProjectionReadSyncProject :: SyncProject | fx)

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
    "verifyNewsRelatedArticleWhitelistLimitProjectionReadFind"
    VerifyNewsRelatedArticleWhitelistLimitProjection
  where
  toKey (Article { id }) = ArticleKey id
  single = false

newtype Article = Article ArticleRecord

instance ToAliases Article where
  toAliases _ = []

type ArticleRecord =
  { id :: ArticleId
  }

type ArticleIndexNeeds =
  { id :: RawIndexOnly ArticleId
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

newtype ArticleKey = ArticleKey ArticleId

derive instance Newtype ArticleKey _
instance ToPrimary ArticleKey where
  toPrimary (ArticleKey id) = toString id

derive instance Eq ArticleKey
derive instance Ord ArticleKey
derive instance Generic ArticleKey _

instance Show ArticleKey where
  show = genericShow

-- Filter

data ArticleFilter

instance IsFilter ArticleFilter Article where
  compile _ _ = unsafeCrashWith "Unreachable"

-- Find

type VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_READ_FIND fx = (verifyNewsRelatedArticleWhitelistLimitProjectionReadFind :: Find Article | fx)
type VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_READ fx =
  VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_READ_FIND
    + VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_READ_SYNC_PROJECT
    + fx

findArticles :: ∀ fx. FindOpt ArticleFilter ArticleId Article -> Run (VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_READ + fx) { hasNextPage :: Boolean, items :: Array Article }
findArticles opt = findMany_ opt { after = opt.after <#> (\id -> ArticleKey id) ▷ persistenceKeyFromKey }

-- Play

play :: ∀ fx. LoadedEvent -> Run (VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_OPS fx) Ɩ
play { event } = case event of
  ArticleDiscarded payload -> onArticleDiscarded payload
  ArticleAddedToNewsRelatedWhitelist payload -> onArticleAddedToNewsRelatedWhitelist payload
  ArticleRemovedFromNewsRelatedWhitelist payload -> onArticleRemovedFromNewsRelatedWhitelist payload
  _ -> ηι

onArticleDiscarded :: ∀ fx. ArticleDiscarded.Payload -> Run (VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_OPS fx) Ɩ
onArticleDiscarded { article } = delete (ArticleKey article)

onArticleAddedToNewsRelatedWhitelist :: ∀ fx. ArticleAddedToNewsRelatedWhitelist.Payload -> Run (VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_OPS fx) Ɩ
onArticleAddedToNewsRelatedWhitelist { article } = add $ Article { id: article }

onArticleRemovedFromNewsRelatedWhitelist :: ∀ fx. ArticleRemovedFromNewsRelatedWhitelist.Payload -> Run (VERIFY_NEWS_RELATED_ARTICLE_WHITELIST_LIMIT_PROJECTION_WRITE_OPS fx) Ɩ
onArticleRemovedFromNewsRelatedWhitelist { article } = delete (ArticleKey article)
