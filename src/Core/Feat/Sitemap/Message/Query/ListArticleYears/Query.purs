module Core.Feat.Sitemap.Message.Query.ListArticleYears.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Feat.Sitemap.Message.Query.ListArticleYears.Payload (Fields, Payload)
import Core.Feat.Sitemap.Message.Query.ListArticleYears.Projection.Projection (ArticleYear(..), findArticleYears)
import Core.Feat.Sitemap.Message.Query.ListArticleYears.Result (Result)
import Core.Feat.Sitemap.Message.Query.ListArticleYears.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Sort as Sort
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Data.Enum (fromEnum)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ListArticleYears = ListArticleYears Payload

derive instance Newtype ListArticleYears _
derive instance Generic ListArticleYears _
derive newtype instance Random ListArticleYears
derive newtype instance WriteForeign ListArticleYears
derive newtype instance ReadForeign ListArticleYears

instance Reflect ListArticleYears where
  reflectName = reflectConstructorName @ListArticleYears

instance IsQuery ListArticleYears State Fields Payload Result where
  description = "List all article years for sitemap"

  cacheStrategy _ = do
    hash <- getReadModelHash @ArticleYear Nothing
    η $ defaultCached hash

  handle (ListArticleYears _) = do
    page <- findArticleYears (defaultFindOpt { limit = Infinite, expectation = QuickNothingBetterThanSlowerSomething, sort = [ Sort.by @"year" Sort.Desc ] })

    η
      { years: page.items <#> \(ArticleYear a) ->
          { year: fromEnum (unwrap a.year)
          , seo: a.seo
          }
      }

