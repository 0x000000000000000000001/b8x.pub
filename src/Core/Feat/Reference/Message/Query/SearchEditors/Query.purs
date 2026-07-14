module Core.Feat.Reference.Message.Query.SearchEditors.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Reference.Message.Query.SearchEditors.Payload (Fields, Payload)
import Core.Feat.Reference.Message.Query.SearchEditors.Projection.Projection (Editor, findEditors)
import Core.Feat.Reference.Message.Query.SearchEditors.Result (Result)
import Core.Feat.Reference.Message.Query.SearchEditors.State (State)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Message.Query.Handle (build)

newtype SearchEditors = SearchEditors Payload

derive instance Newtype SearchEditors _
derive instance Generic SearchEditors _
derive newtype instance Random SearchEditors
derive newtype instance WriteForeign SearchEditors
derive newtype instance ReadForeign SearchEditors

instance Reflect SearchEditors where
  reflectName = reflectConstructorName @SearchEditors

instance IsQuery SearchEditors State Fields Payload Result where
  description = "Search editors"

  cacheStrategy _ = do
    hash <- getReadModelHash @Editor Nothing
    η $ defaultCached hash

  handle (SearchEditors { filter, limit: BoundedLimit limit_, expectation, after, needs }) = do
    page <- findEditors (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after })

    η
      { editors: page.items <#> unwrap ▷ \e ->
          { id: build needs.id e.id
          , name: build needs.name e.name
          , legacyBookIds: build needs.legacyBookIds e.legacyBookIds
          }
      , limit: limit_
      , hasNextPage: page.hasNextPage
      }
