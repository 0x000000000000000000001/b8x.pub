module Core.Mod.Author.Message.Query.Build where

import Proem

import Core.Message.Query.Handle (build)
import Core.Mod.Author.Message.Query.Opt (AuthorOpt, AuthorInnerNeeds)
import Core.Mod.Author.Message.Query.Result as Result
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name (Name)
import Core.Mod.Author.Biography.Biography (Biography)
import Core.Message.Query.Payload as QueryPayload
import Core.Message.Query.Result as QueryResult
import Data.Maybe (Maybe(..))
import Core.Mod.Image.Image (Image)
import Core.Mod.Image.Message.Query.Build (buildImage)

buildAuthor :: String -> QueryPayload.Need AuthorOpt AuthorInnerNeeds -> Maybe { id :: AuthorId, name :: Name, biography :: Biography, portrait :: Maybe Image } -> QueryResult.Return (Maybe Result.Author)
buildAuthor _ QueryPayload.NotNeeded _ = QueryResult.NotGivenBecauseNotNeeded
buildAuthor urlBase (QueryPayload.Needed _ innerNeeds) mAu = QueryResult.Given do
  au <- mAu
  Just
    { id: build innerNeeds.id au.id
    , name: build innerNeeds.name au.name
    , biography: build innerNeeds.biography au.biography
    , portrait: case innerNeeds.portrait of
        QueryPayload.NotNeeded -> QueryResult.NotGivenBecauseNotNeeded
        QueryPayload.Needed pOpt pInnerNeeds -> QueryResult.Given (au.portrait <#> buildImage urlBase pOpt pInnerNeeds)
    }
