module Core.Feat.Reference.Message.Query.SearchAuthors.Query where
import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Reference.Message.Query.SearchAuthors.Payload (Fields, Payload)
import Core.Feat.Reference.Message.Query.SearchAuthors.Result (Result)
import Core.Feat.Reference.Message.Query.SearchAuthors.State (State)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Projection.Finder.Finder (defaultFindOpt, getReadModelHash)
import Core.Mod.Projection.Finder.Filter (Limit(..))
import Core.Feat.Reference.Message.Query.SearchAuthors.Projection.Projection (Author, findAuthors)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype, unwrap)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Message.Query.Handle (build)
import Config.PublicConfig (askPublicConfig)
import Core.Mod.Image.Message.Query.Build (buildImage)
import Core.Message.Query.Payload as QueryPayload
import Core.Message.Query.Result as QueryResult

newtype SearchAuthors = SearchAuthors Payload

derive instance Newtype SearchAuthors _
derive instance Generic SearchAuthors _
derive newtype instance Random SearchAuthors
derive newtype instance WriteForeign SearchAuthors
derive newtype instance ReadForeign SearchAuthors

instance Reflect SearchAuthors where
  reflectName = reflectConstructorName @SearchAuthors

instance IsQuery SearchAuthors State Fields Payload Result where
  description = "Search authors"

  cacheStrategy _ = do
    hash <- getReadModelHash @Author Nothing
    η $ defaultCached hash

  handle (SearchAuthors { filter, limit: BoundedLimit limit_, expectation, after, needs }) = do
    config <- askPublicConfig
    page <- findAuthors (defaultFindOpt { filter = filter, limit = Finite limit_, expectation = expectation, after = after })

    η
      { authors: page.items <#> unwrap ▷ \a ->
          { id: build needs.id a.id
          , name: build needs.name a.name
          , biography: build needs.biography a.biography
          , legacyIds: build needs.legacyIds a.legacyIds
          , portrait: case needs.portrait of
              QueryPayload.NotNeeded -> QueryResult.NotGivenBecauseNotNeeded
              QueryPayload.Needed pOpt pInnerNeeds -> QueryResult.Given (a.portrait <#> buildImage config.objectStorage.urlBase pOpt pInnerNeeds)
          }
      , limit: limit_
      , hasNextPage: page.hasNextPage
      }
