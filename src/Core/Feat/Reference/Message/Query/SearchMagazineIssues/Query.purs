module Core.Feat.Reference.Message.Query.SearchMagazineIssues.Query where
import Data.Maybe (Maybe(..))

import Proem
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Config.PublicConfig (askPublicConfig)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Payload (Fields, Payload)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Result (Result)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.State (State)
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Projection.Projection (MagazineIssue, findMagazineIssues)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Mod.Book.Cover.Message.Query.Build (buildCover)
import Core.Message.Query.Handle (build)

newtype SearchMagazineIssues = SearchMagazineIssues Payload

derive instance Newtype SearchMagazineIssues _
derive instance Generic SearchMagazineIssues _
derive newtype instance Random SearchMagazineIssues
derive newtype instance WriteForeign SearchMagazineIssues
derive newtype instance ReadForeign SearchMagazineIssues

instance Reflect SearchMagazineIssues where
  reflectName = reflectConstructorName @SearchMagazineIssues

instance IsQuery SearchMagazineIssues State Fields Payload Result where
  description = "Search magazine issues"

  cacheStrategy _ = do
    hash <- getReadModelHash @MagazineIssue Nothing
    η $ defaultCached hash

  handle (SearchMagazineIssues { sort, filter, limit: BoundedLimit limit_, expectation, after, needs }) = do
    config <- askPublicConfig

    page <- findMagazineIssues (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after, sort = sort })

    η
      { magazineIssues: page.items <#> unwrap ▷ \e ->
          { id: build needs.id e.id
          , name: build needs.name e.name
          , legacyId: build needs.legacyId e.legacyId
          , special: build needs.special e.special
          , complement: build needs.complement e.complement
          , number: build needs.number e.number
          , cover: buildCover config.objectStorage.urlBase needs.cover e.cover
          , slug: build needs.slug e.slug
          , seoUpdatedAt: build needs.seoUpdatedAt e.seo.updatedAt
          }
      , limit: limit_
      , hasNextPage: page.hasNextPage
      }
