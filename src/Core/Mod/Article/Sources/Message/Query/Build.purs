module Core.Mod.Article.Sources.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as Payload
import Core.Message.Query.Result as Result
import Core.Mod.Article.Sources.Sources (Sources)
import Core.Mod.Html.Url (absolutizeOurObjectStorageUrls, relativizeCleanOurUrls)

buildSources :: Payload.Need Ɩ Ɩ -> Sources -> Result.Return Sources
buildSources Payload.NotNeeded _ = Result.NotGivenBecauseNotNeeded
buildSources (Payload.Needed _ _) sources = Result.Given $
  let treatUrls h = relativizeCleanOurUrls $ absolutizeOurObjectStorageUrls h
  in sources <#> treatUrls
