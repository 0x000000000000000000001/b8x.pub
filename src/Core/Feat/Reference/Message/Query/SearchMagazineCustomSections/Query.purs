module Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Query where
import Data.Maybe (Maybe(..))

import Proem
import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Payload (Fields, Payload)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Result (Result)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.State (State)
import Core.Feat.Reference.Message.Query.SearchMagazineCustomSections.Projection.Projection (CustomSection, findCustomSections)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Mod.Projection.Finder.Sort (noSort)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Message.Query.Handle (build)

newtype SearchMagazineCustomSections = SearchMagazineCustomSections Payload

derive instance Newtype SearchMagazineCustomSections _
derive instance Generic SearchMagazineCustomSections _
derive newtype instance Random SearchMagazineCustomSections
derive newtype instance WriteForeign SearchMagazineCustomSections
derive newtype instance ReadForeign SearchMagazineCustomSections

instance Reflect SearchMagazineCustomSections where
  reflectName = reflectConstructorName @SearchMagazineCustomSections

instance IsQuery SearchMagazineCustomSections State Fields Payload Result where
  description = "Search magazine custom sections"

  cacheStrategy _ = do
    hash <- getReadModelHash @CustomSection Nothing
    η $ defaultCached hash

  handle (SearchMagazineCustomSections { filter, limit: BoundedLimit limit_, expectation, after, needs }) = do
    page <- findCustomSections (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after, sort = noSort })

    η
      { customSections: page.items <#> unwrap ▷ \e ->
          { id: build needs.id e.id
          , magazineIssue: build needs.magazineIssue e.magazineIssue
          , name: build needs.name e.name
          }
      , limit: limit_
      , hasNextPage: page.hasNextPage
      }
