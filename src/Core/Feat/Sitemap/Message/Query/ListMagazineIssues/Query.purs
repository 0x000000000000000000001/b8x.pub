module Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Payload (Fields, Payload)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Projection.Projection (MagazineIssue(..), findMagazineIssues)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.Result (Result)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.State (State)
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Sort as Sort
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype ListMagazineIssues = ListMagazineIssues Payload

derive instance Newtype ListMagazineIssues _
derive instance Generic ListMagazineIssues _
derive newtype instance Random ListMagazineIssues
derive newtype instance WriteForeign ListMagazineIssues
derive newtype instance ReadForeign ListMagazineIssues

instance Reflect ListMagazineIssues where
  reflectName = reflectConstructorName @ListMagazineIssues

instance IsQuery ListMagazineIssues State Fields Payload Result where
  description = "List all magazine issues for sitemap"

  cacheStrategy _ = do
    hash <- getReadModelHash @MagazineIssue Nothing
    η $ defaultCached hash

  handle (ListMagazineIssues _) = do
    page <- findMagazineIssues (defaultFindOpt { limit = Finite 50000, expectation = QuickNothingBetterThanSlowerSomething, sort = [ Sort.by @"number" Sort.Desc ] })

    η
      { magazineIssues: page.items <#> \(MagazineIssue a) ->
          { id: a.id
          , number: a.number
          , slug: a.slug
          , seo: a.seo
          }
      }

