module Core.Feat.Sitemap.Message.Query.ListYearArticles.Query where

import Proem

import Core.Feat.Sitemap.Message.Query.ListYearArticles.Payload (Fields, Payload)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Projection.Projection (Article(..), findArticles, ArticleFilter(..))
import Core.Feat.Sitemap.Message.Query.ListYearArticles.Result (Result)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Sort as Sort
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Enum (fromEnum)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ListYearArticles = ListYearArticles Payload

derive instance Newtype ListYearArticles _
derive instance Generic ListYearArticles _
derive newtype instance Random ListYearArticles
derive newtype instance WriteForeign ListYearArticles
derive newtype instance ReadForeign ListYearArticles

instance Reflect ListYearArticles where
  reflectName = reflectConstructorName @ListYearArticles

instance IsQuery ListYearArticles State Fields Payload Result where
  description = "List all articles by year for sitemap"

  cacheStrategy _ = do
    hash <- getReadModelHash @Article Nothing
    η $ defaultCached hash

  handle (ListYearArticles { year }) = do
    page <- findArticles (defaultFindOpt { filter = Just (ArticleHasYear year), limit = Infinite, expectation = QuickNothingBetterThanSlowerSomething, sort = [ Sort.by @"id" Sort.Desc ] })

    η
      { articles: page.items <#> \(Article a) ->
          { id: a.id
          , slug: a.slug
          , year: fromEnum (unwrap a.year)
          , seo: a.seo
          }
      }

