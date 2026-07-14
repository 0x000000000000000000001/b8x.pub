module Core.Feat.Review.Message.Query.SearchArticles.Query where

import Proem

import Config.PublicConfig (askPublicConfig)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Message.Query.Handle (build)
import Core.Mod.Book.Message.Query.Build (buildBooks, buildBook)
import Core.Mod.Article.Illustrations.Message.Query.Build (buildIllustrations, buildIllustration)
import Core.Mod.Author.Message.Query.Build (buildAuthor)
import Core.Mod.Article.Lead.Message.Query.Build (buildLead)
import Core.Mod.Article.Title.Message.Query.Build (buildTitle)
import Core.Mod.Article.Notes.Message.Query.Build (buildNotes)
import Core.Mod.Article.Sources.Message.Query.Build (buildSources)
import Core.Mod.Article.Content.Message.Query.Build (buildContent)
import Core.Feat.Review.Message.Query.SearchArticles.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.SearchArticles.Result (Result)
import Core.Feat.Review.Message.Query.SearchArticles.State (State)
import Core.Feat.Review.Message.Query.SearchArticles.Projection.Projection (Article(..), findArticles)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Maybe (Maybe(..))
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result (Return(..))
import Core.Mod.Article.Projection.MagazineIssue as Projected
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype SearchArticles = SearchArticles Payload

derive instance Newtype SearchArticles _
derive instance Generic SearchArticles _
derive newtype instance Random SearchArticles
derive newtype instance WriteForeign SearchArticles
derive newtype instance ReadForeign SearchArticles

instance Reflect SearchArticles where
  reflectName = reflectConstructorName @SearchArticles

instance IsQuery SearchArticles State Fields Payload Result where
  description = "Search articles"

  cacheStrategy _ = do
    hash <- getReadModelHash @Article Nothing
    η $ defaultCached hash

  handle (SearchArticles { sort, filter, expectation, limit: BoundedLimit limit_, after, needs }) = do
    config <- askPublicConfig
    page <- findArticles (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after, sort = sort })

    η
      { articles: page.items <#> \(Article a) ->
          let
            magazineSection = case needs.magazineSection of
              NotNeeded -> NotGivenBecauseNotNeeded
              Needed _ _ -> case a.magazineIssue of
                Nothing -> Given Nothing
                Just (Projected.MagazineIssue mi) -> Given $
                  case mi.section of
                    Just s -> Just $ s <#> \{ name } -> name
                    Nothing -> Nothing
            magazineIssuePageNumber = case needs.magazineIssuePageNumber of
              NotNeeded -> NotGivenBecauseNotNeeded
              Needed _ _ -> case a.magazineIssue of
                Nothing -> Given Nothing
                Just (Projected.MagazineIssue mi) -> Given mi.pageNumber
          in
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
            , magazineSection
            , magazineIssuePageNumber
            , seoUpdatedAt: build needs.seoUpdatedAt a.seo.updatedAt
            }
      , limit: limit_
      , hasNextPage: page.hasNextPage
      }
