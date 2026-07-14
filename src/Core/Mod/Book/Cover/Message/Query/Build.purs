module Core.Mod.Book.Cover.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as QueryPayload
import Core.Message.Query.Result as QueryResult
import Core.Mod.Book.Cover.Message.Query.Opt (CoverOpt, CoverInnerNeeds)
import Core.Mod.Image.Image as Projection
import Core.Mod.Image.Message.Query.Result as Result
import Core.Mod.Image.Message.Query.Build (buildImage)
import Data.Maybe (Maybe(..))

buildCover :: String -> QueryPayload.Need CoverOpt CoverInnerNeeds -> Maybe Projection.Image -> QueryResult.Return (Maybe Result.Image)
buildCover _ QueryPayload.NotNeeded _ = QueryResult.NotGivenBecauseNotNeeded
buildCover urlBase (QueryPayload.Needed opt innerNeeds) maybeImage = QueryResult.Given do
  image <- maybeImage

  let
    Projection.Image record = image
    threshold = opt.onlyIfWidthGreaterThan ??⇒ 0

  if record.dimensions.width >= threshold then Just (buildImage urlBase ι innerNeeds image)
  else Nothing
