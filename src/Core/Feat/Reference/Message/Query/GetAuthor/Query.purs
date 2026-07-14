module Core.Feat.Reference.Message.Query.GetAuthor.Query where

import Proem

import Core.Message.Query.Query (class IsQuery, defaultCached)
import Core.Feat.Reference.Message.Query.GetAuthor.Payload (Fields, Payload)
import Core.Feat.Reference.Message.Query.GetAuthor.Result (Result)
import Core.Feat.Reference.Message.Query.GetAuthor.State (State)
import Core.Mod.Projection.Finder.Finder (getReadModelHash)
import Core.Feat.Reference.Message.Query.GetAuthor.Projection.Projection (Author(..), AuthorKey(..), findAuthorById)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Util.Type.Random (class Random)
import Util.Type.Type (class Reflect, reflectConstructorName)
import Core.Message.Query.Handle (build)
import Config.PublicConfig (askPublicConfig)
import Core.Mod.Image.Message.Query.Build (buildImage)
import Core.Message.Query.Payload as QueryPayload
import Core.Message.Query.Result as QueryResult

newtype GetAuthor = GetAuthor Payload

derive instance Newtype GetAuthor _
derive instance Generic GetAuthor _
derive newtype instance Random GetAuthor
derive newtype instance WriteForeign GetAuthor
derive newtype instance ReadForeign GetAuthor

instance Reflect GetAuthor where
  reflectName = reflectConstructorName @GetAuthor

instance IsQuery GetAuthor State Fields Payload Result where
  description = "Get an author"

  cacheStrategy (GetAuthor { id }) = do
    hash <- getReadModelHash @Author (Just (AuthorKey id))
    η $ defaultCached hash

  handle (GetAuthor { id, needs }) = do
    config <- askPublicConfig
    mAuthor <- findAuthorById id
    case mAuthor of
      Just (Author a) -> do
        η $ Just
          { id: build needs.id a.id
          , name: build needs.name a.name
          , biography: build needs.biography a.biography
          , legacyIds: build needs.legacyIds a.legacyIds
          , portrait: case needs.portrait of
              QueryPayload.NotNeeded -> QueryResult.NotGivenBecauseNotNeeded
              QueryPayload.Needed pOpt pInnerNeeds -> QueryResult.Given (a.portrait <#> buildImage config.objectStorage.urlBase pOpt pInnerNeeds)
          }
      Nothing -> do
        η (Nothing :: Result)
