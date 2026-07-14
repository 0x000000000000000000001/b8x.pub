module Core.Feat.Newsletter.Message.Query.SearchNewsletters.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Message.Query.Handle (build)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Payload (Fields, Payload)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Result (Result)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.Projection.Projection (Newsletter(..), findNewsletters)
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Core.Feat.Newsletter.Message.Query.SearchNewsletters.State (State)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype SearchNewsletters = SearchNewsletters Payload

derive instance Newtype SearchNewsletters _
derive instance Generic SearchNewsletters _
derive newtype instance Random SearchNewsletters
derive newtype instance WriteForeign SearchNewsletters
derive newtype instance ReadForeign SearchNewsletters

instance Reflect SearchNewsletters where
  reflectName = reflectConstructorName @SearchNewsletters

instance IsQuery SearchNewsletters State Fields Payload Result where
  description = "Search newsletters"

  cacheStrategy _ = do
    hash <- getReadModelHash @Newsletter Nothing
    η $ defaultCached hash

  handle (SearchNewsletters { sort, filter, expectation, limit: BoundedLimit limit_, after, needs }) = do
    page <- findNewsletters (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after, sort = sort })

    η
      { newsletters: page.items <#> \(Newsletter n) ->
          { id: build needs.id n.id
          , scheduledFor: build needs.scheduledFor n.scheduledFor
          , articles: build needs.articles n.articles
          }
      , hasMore: page.hasNextPage
      }
