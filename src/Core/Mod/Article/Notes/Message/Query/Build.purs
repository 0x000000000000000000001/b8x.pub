module Core.Mod.Article.Notes.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as Payload
import Core.Message.Query.Result as Result
import Core.Mod.Article.Notes.Notes (Notes)
import Core.Mod.Html.Url (absolutizeOurObjectStorageUrls, relativizeCleanOurUrls)

buildNotes :: Payload.Need Ɩ Ɩ -> Notes -> Result.Return Notes
buildNotes Payload.NotNeeded _ = Result.NotGivenBecauseNotNeeded
buildNotes (Payload.Needed _ _) notes = Result.Given $
  let treatUrls h = relativizeCleanOurUrls $ absolutizeOurObjectStorageUrls h
  in notes <#> treatUrls
