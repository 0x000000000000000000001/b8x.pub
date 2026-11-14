module Core.Feat.Review.Message.Query.SearchNewsTopics.Query where

import Proem

import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Review.Message.Query.SearchNewsTopics.Payload (Fields, Payload)
import Core.Feat.Review.Message.Query.SearchNewsTopics.Projection.Projection (NewsTopic(..), findNewsTopics)
import Core.Feat.Review.Message.Query.SearchNewsTopics.Result (Result)
import Core.Feat.Review.Message.Query.SearchNewsTopics.State (State)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash, HashScope(..))
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Message.Query.Handle (build)

newtype SearchNewsTopics = SearchNewsTopics Payload

derive instance Newtype SearchNewsTopics _
derive instance Generic SearchNewsTopics _
derive newtype instance Random SearchNewsTopics
derive newtype instance WriteForeign SearchNewsTopics
derive newtype instance ReadForeign SearchNewsTopics

instance Reflect SearchNewsTopics where
  reflectName = reflectConstructorName @SearchNewsTopics

instance IsQuery SearchNewsTopics State Fields Payload Result where
  description = "Search news topics"

  cacheStrategy _ = do
    hash <- getReadModelHash @NewsTopic HashAll
    η $ defaultCached hash

  handle (SearchNewsTopics { filter, limit: BoundedLimit limit_, expectation, after, needs: { id: needId, searchInput: needSearchInput } }) = do
    { items, hasNextPage } <- findNewsTopics (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after })

    η
      { newsTopics: items <#> \(NewsTopic { id, searchInput }) ->
          { id: build needId id
          , searchInput: build needSearchInput searchInput
          }
      , limit: limit_
      , hasNextPage
      }
