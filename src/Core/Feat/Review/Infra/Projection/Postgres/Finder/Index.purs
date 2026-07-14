module Core.Feat.Review.Infra.Projection.Postgres.Finder.Index where

import Proem

import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Projection as ListNewsRelatedArticles
import Core.Feat.Review.Message.Query.ListMostReadArticles.Projection.Projection as ListMostReadArticles
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Projection.Projection as ListNewsletterArticles
import Core.Feat.Review.Message.Query.GetArticle.Projection.Projection as GetArticle
import Core.Feat.Review.Message.Query.GetArticleQuote.Projection.Projection as GetArticleQuote
import Core.Feat.Review.Message.Query.GetFrontPage.Projection.Projection as GetFrontPage
import Core.Feat.Review.Message.Query.VerifyNewsTopicLimit.Projection.Projection as VerifyNewsTopicLimit
import Core.Feat.Review.Message.Query.VerifyArticleLegacyIdUniqueness.Projection.Projection as VerifyArticleLegacyIdUniqueness
import Core.Feat.Review.Message.Command.WriteArticle.Projection.Projection as WriteArticle
import Core.Feat.Review.Message.Query.VerifyArticleSlugUniqueness.Projection.Projection as VerifyArticleSlugUniqueness
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection as SearchArticles
import Core.Feat.Review.Message.Query.VerifyNewsRelatedArticleWhitelistLimit.Projection.Projection as VerifyNewsRelatedArticleWhitelistLimit
import Core.Mod.Projection.Index (PROJECTION_READ_SYNC_PROJECT)
import Infra.Client.Postgres.Postgres (READER_POSTGRES_EDGE_CLIENT)
import Infra.Projection.Postgres.Finder.Finder as Base
import Run (AFF, EFFECT)
import Type.Row (type (+))
import Util.Run.Router (RouterBuilder)

onProjectionReadFind
  :: ∀ fx' a
   . RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
  -> RouterBuilder (PROJECTION_READ_SYNC_PROJECT + READER_POSTGRES_EDGE_CLIENT + EFFECT + AFF + fx') a
onProjectionReadFind = Base.onProjectionReadFind @GetArticle.Article
  ◁ Base.onProjectionReadFind @GetArticleQuote.Quote
  ◁ Base.onProjectionReadFind @GetFrontPage.Article
  ◁ Base.onProjectionReadFind @GetFrontPage.FrontPage
  ◁ Base.onProjectionReadFind @ListMostReadArticles.Article
  ◁ Base.onProjectionReadFind @ListNewsRelatedArticles.Article
  ◁ Base.onProjectionReadFind @ListNewsRelatedArticles.NewsTopic
  ◁ Base.onProjectionReadFind @ListNewsletterArticles.Article
  ◁ Base.onProjectionReadFind @VerifyNewsTopicLimit.NewsTopic
  ◁ Base.onProjectionReadFind @VerifyArticleLegacyIdUniqueness.Article
  ◁ Base.onProjectionReadFind @SearchArticles.Article
  ◁ Base.onProjectionReadFind @SearchArticles.NewsTopic
  ◁ Base.onProjectionReadFind @WriteArticle.Article
  ◁ Base.onProjectionReadFind @VerifyArticleSlugUniqueness.Article
  ◁ Base.onProjectionReadFind @VerifyNewsRelatedArticleWhitelistLimit.Article
