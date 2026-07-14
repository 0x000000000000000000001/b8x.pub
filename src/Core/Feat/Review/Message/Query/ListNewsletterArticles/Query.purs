module Core.Feat.Review.Message.Query.ListNewsletterArticles.Query where

import Proem

import Config.PublicConfig (askPublicConfig)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Message.Query.Handle (build)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Result (Result)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.State (State)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Field.Newsletter as Newsletter
import Core.Mod.Article.Illustrations.Message.Query.Build (buildIllustrations, buildIllustration)
import Core.Mod.Article.Projection.Newsletters as Newsletters
import Core.Mod.Article.Lead.Message.Query.Build (buildLead)
import Core.Mod.Article.Title.Message.Query.Build (buildTitle)
import Core.Mod.Article.Notes.Message.Query.Build (buildNotes)
import Core.Mod.Article.Sources.Message.Query.Build (buildSources)
import Core.Mod.Article.Content.Message.Query.Build (buildContent)
import Core.Mod.Author.Message.Query.Build (buildAuthor)
import Core.Mod.Book.Message.Query.Build (buildBooks, buildBook)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Projection.Projection (Article(..), findArticles)
import Core.Feat.Review.Message.Query.ListNewsletterArticles.Projection.Projection as ArticleFilter
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Sort as Sort
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ListNewsletterArticles = ListNewsletterArticles Payload

derive instance Newtype ListNewsletterArticles _
derive instance Generic ListNewsletterArticles _
derive newtype instance Random ListNewsletterArticles
derive newtype instance WriteForeign ListNewsletterArticles
derive newtype instance ReadForeign ListNewsletterArticles

instance Reflect ListNewsletterArticles where
  reflectName = reflectConstructorName @ListNewsletterArticles

instance IsQuery ListNewsletterArticles State Fields Payload Result where
  description = "List recent newsletter articles"

  cacheStrategy _ = do
    hash <- getReadModelHash @Article Nothing
    η $ defaultCached [ hash, "0" ]

  handle (ListNewsletterArticles { newsletter, blacklist, needs, illustrationRequired }) = do
    config <- askPublicConfig
    let
      baseFilter = case newsletter of
        Newsletter.Recent -> ArticleFilter.ArticleIsInScheduledNewsletter
        Newsletter.Month { month, year } -> ArticleFilter.ArticleIsInNewsletterHavingMonthYear { month, year }
        Newsletter.Id id -> ArticleFilter.ArticleIsInNewsletterHavingId id

      blacklistFilter = Array.foldr (\id acc -> ArticleFilter.ArticleAnd { left: acc, right: ArticleFilter.ArticleHasNotId id }) baseFilter blacklist

      targetFilter =
        if illustrationRequired then
          ArticleFilter.ArticleAnd { left: blacklistFilter, right: ArticleFilter.ArticleHasAtLeastOneIllustration true }
        else
          blacklistFilter

    articlesPage <- findArticles
      ( defaultFindOpt
          { filter = Just targetFilter
          , limit = case newsletter of
              Newsletter.Recent -> Finite 12
              _ -> Infinite
          , sort = [ Sort.by @"newsletters.mostRecent.scheduledFor" Sort.Desc, Sort.by @"newsletters.mostRecent.index" Sort.Asc ]
          }
      )

    η
      { articles: articlesPage.items <#> \(Article a) ->
          { id: build needs.id a.id
          , legacyId: build needs.legacyId a.legacyId
          , title: buildTitle needs.title a.title
          , lead: buildLead needs.lead a.lead a.content
          , notes: buildNotes needs.notes a.notes
          , sources: buildSources needs.sources a.sources
          , content: buildContent needs.content a.content
          , theme: build needs.theme a.theme
          , books: buildBooks needs.books a.books (buildBook config.objectStorage.urlBase)
          , author: buildAuthor config.objectStorage.urlBase needs.author a.author
          , illustrations: buildIllustrations needs.illustrations a.illustrations a.books (buildIllustration config.objectStorage.urlBase)
          , slug: build needs.slug a.slug
          , newsletters: build needs.newsletters
              ( let
                  (Newsletters.Newsletters n) = a.newsletters
                in
                  n.newsletters <#> \p -> { id: p.id, index: p.index, scheduledFor: { instant: p.scheduledFor.instant, month: p.scheduledFor.month, year: p.scheduledFor.year } }
              )
          }
      }
