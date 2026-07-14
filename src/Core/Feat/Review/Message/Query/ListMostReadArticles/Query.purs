module Core.Feat.Review.Message.Query.ListMostReadArticles.Query where

import Proem

import Config.PublicConfig (askPublicConfig)
import Core.Message.Query.Handle (build)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Review.Message.Query.ListMostReadArticles.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.ListMostReadArticles.Projection.Projection (Article(..), findArticles)
import Core.Feat.Review.Message.Query.ListMostReadArticles.Projection.Projection as ArticleFilter
import Core.Feat.Review.Message.Query.ListMostReadArticles.Result (Result)
import Core.Feat.Review.Message.Query.ListMostReadArticles.State (State)
import Core.Mod.Article.Content.Message.Query.Build (buildContent)
import Core.Mod.Article.Illustrations.Message.Query.Build (buildIllustrations, buildIllustration)
import Core.Mod.Article.Lead.Message.Query.Build (buildLead)
import Core.Mod.Article.Title.Message.Query.Build (buildTitle)
import Core.Mod.Article.Notes.Message.Query.Build (buildNotes)
import Core.Mod.Article.Sources.Message.Query.Build (buildSources)
import Core.Mod.Author.Message.Query.Build (buildAuthor)
import Core.Mod.Book.Message.Query.Build (buildBooks, buildBook)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Finder (getReadModelHash, defaultFindOpt)
import Core.Mod.Projection.Finder.Sort as Sort
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ListMostReadArticles = ListMostReadArticles Payload

derive instance Newtype ListMostReadArticles _
derive instance Generic ListMostReadArticles _
derive newtype instance Random ListMostReadArticles
derive newtype instance WriteForeign ListMostReadArticles
derive newtype instance ReadForeign ListMostReadArticles

instance Reflect ListMostReadArticles where
  reflectName = reflectConstructorName @ListMostReadArticles

instance IsQuery ListMostReadArticles State Fields Payload Result where
  description = "List most read articles"

  cacheStrategy _ = do
    hash <- getReadModelHash @Article Nothing
    η $ defaultCached hash

  handle (ListMostReadArticles { theme, blacklist, needs }) = do
    config <- askPublicConfig

    let
      baseFilter = ArticleFilter.ArticleHasAtLeastOneIllustration true
      finalFilter = case theme of
        Just t -> ArticleFilter.ArticleAnd { left: baseFilter, right: ArticleFilter.ArticleHasTheme t }
        Nothing -> baseFilter
      finalFilterWithoutFrontPage = Array.foldl (\f id -> ArticleFilter.ArticleAnd { left: f, right: ArticleFilter.ArticleHasNotId id }) finalFilter blacklist

    page <- findArticles (defaultFindOpt { filter = Just finalFilterWithoutFrontPage, limit = Finite 12, expectation = SlowerSomethingBetterThanQuickNothing, sort = [ Sort.by @"readCount" Sort.Desc, Sort.by @"writtenAt" Sort.Desc ] })

    η
      { articles: page.items <#> \(Article a) ->
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
          }
      }
