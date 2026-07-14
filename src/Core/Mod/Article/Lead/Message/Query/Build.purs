module Core.Mod.Article.Lead.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as Payload
import Core.Message.Query.Result as Result
import Core.Mod.Article.Lead.Message.Query.Opt (LeadOpt, LeadInnerNeeds)
import Core.Mod.Article.Lead.Message.Query.Result as ResultLead
import Core.Mod.Article.Lead.Lead (Lead)
import Core.Mod.Article.Lead.Clean as LeadClean
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Content.Excerpt.Excerpt as ContentExcerpt
import Data.Maybe (Maybe(..))
import Core.Mod.Html.Url (absolutizeOurObjectStorageUrls, relativizeCleanOurUrls)

buildLead :: Payload.Need LeadOpt LeadInnerNeeds -> Lead -> Content -> Result.Return ResultLead.Lead
buildLead Payload.NotNeeded _ _ = Result.NotGivenBecauseNotNeeded
buildLead (Payload.Needed { fallbackToContentExcerpt, untagHtml } { isFallback: isFallbackNeed }) mLead content = Result.Given
  let
    treatUrls h = relativizeCleanOurUrls $ absolutizeOurObjectStorageUrls h
  in
    { lead: Result.Given $ case mLead of
        Just l -> Just $ treatUrls (LeadClean.cleanHtml untagHtml l)
        Nothing -> case fallbackToContentExcerpt of
          Just opt -> Just (treatUrls (ContentExcerpt.excerpt content untagHtml opt.newlineReplacement opt.cutStrategy))
          Nothing -> Nothing
    , isFallback: case isFallbackNeed of
        Payload.NotNeeded -> Result.NotGivenBecauseNotNeeded
        Payload.Needed _ _ -> Result.Given $ case mLead of
          Just _ -> false
          Nothing -> case fallbackToContentExcerpt of
            Just _ -> true
            Nothing -> false
    }
