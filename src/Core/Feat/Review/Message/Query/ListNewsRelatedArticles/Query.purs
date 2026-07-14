module Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Query where

import Proem

import Config.PublicConfig (askPublicConfig)
import Core.Message.Query.Handle (build)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Projection (Article(..), NewsTopic(..), findAllNewsTopics, findArticles, parFindArticles)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Projection.Projection as ArticleFilter
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.Result (Result)
import Core.Feat.Review.Message.Query.ListNewsRelatedArticles.State (State)
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
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Sort as Sort
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array as Array
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ListNewsRelatedArticles = ListNewsRelatedArticles Payload

derive instance Newtype ListNewsRelatedArticles _
derive instance Generic ListNewsRelatedArticles _
derive newtype instance Random ListNewsRelatedArticles
derive newtype instance WriteForeign ListNewsRelatedArticles
derive newtype instance ReadForeign ListNewsRelatedArticles

instance Reflect ListNewsRelatedArticles where
  reflectName = reflectConstructorName @ListNewsRelatedArticles

instance IsQuery ListNewsRelatedArticles State Fields Payload Result where
  description = "List news related articles"

  cacheStrategy _ = do
    hash1 <- getReadModelHash @NewsTopic Nothing
    hash2 <- getReadModelHash @Article Nothing
    η $ defaultCached [ hash1, hash2 ]

  handle (ListNewsRelatedArticles { theme, blacklist, needs }) = do
    config <- askPublicConfig
    topics <- findAllNewsTopics

    let
      whitelistedFilter = ArticleFilter.ArticleIsAddedToNewsRelatedWhitelist true
      blacklistedFilter = ArticleFilter.ArticleIsAddedToNewsRelatedBlacklist false
      whitelistQueryFilter = ArticleFilter.ArticleAnd { left: whitelistedFilter, right: blacklistedFilter }
      whitelistQueryFilterWithoutFrontPage = Array.foldl (\f id -> ArticleFilter.ArticleAnd { left: f, right: ArticleFilter.ArticleHasNotId id }) whitelistQueryFilter blacklist

    whitelistPage <- findArticles (defaultFindOpt { filter = Just whitelistQueryFilterWithoutFrontPage, limit = Finite 12, expectation = SlowerSomethingBetterThanQuickNothing, sort = Sort.noSort })

    let
      headArticles = whitelistPage.items

    let
      queries = topics <#> \(NewsTopic topic) ->
        let
          titleStr = toString topic.searchInput

          baseFilter =
            ArticleFilter.ArticleAnd { left: ArticleFilter.ArticleMatches { query: titleStr, weight: 1.0 }, right: ArticleFilter.ArticleHasAtLeastOneIllustration true }
          themeFilter = case theme of
            Just t -> ArticleFilter.ArticleAnd { left: baseFilter, right: ArticleFilter.ArticleHasTheme t }
            Nothing -> baseFilter

          finalFilter = ArticleFilter.ArticleAnd { left: themeFilter, right: blacklistedFilter }
          finalFilterWithoutFrontPage = Array.foldl (\f id -> ArticleFilter.ArticleAnd { left: f, right: ArticleFilter.ArticleHasNotId id }) finalFilter blacklist
        in
          defaultFindOpt
            { filter = Just finalFilterWithoutFrontPage
            , limit = Finite 12
            , expectation = SlowerSomethingBetterThanQuickNothing
            }

    results <- parFindArticles queries

    let
      allArrays = results <#> _.items

      roundRobin :: ∀ a. Array (Array a) -> Array a
      roundRobin arrays = go arrays []
        where
        go [] acc = acc
        go arrs acc =
          let
            heads = Array.mapMaybe Array.head arrs
            tails = Array.mapMaybe Array.tail arrs # Array.filter (\a -> Array.length a > 0)
          in
            if Array.null heads then acc else go tails (acc <> heads)

      roundRobined = roundRobin allArrays

      extractId (Article a) = toString a.id

      deduplicated = Array.nubByEq (\a b -> extractId a == extractId b) roundRobined

      headIds = map extractId headArticles
      filteredTail = Array.filter (\a -> not (Array.elem (extractId a) headIds)) deduplicated

    let
      combinedArticles = headArticles <> filteredTail
      finalArticles = Array.take 12 combinedArticles

    η
      { articles: finalArticles <#> \(Article a) ->
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
