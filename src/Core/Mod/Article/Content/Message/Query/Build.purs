module Core.Mod.Article.Content.Message.Query.Build where

import Proem

import Core.Message.Query.Payload as QueryPayload
import Core.Message.Query.Result as QueryResult
import Core.Mod.Article.Content.Content (Content)
import Core.Mod.Article.Content.Message.Query.Opt (ContentOpt, ContentInnerNeeds, ExcerptOpt(..))
import Core.Mod.Article.Content.Excerpt.Excerpt as ContentExcerpt
import Core.Mod.Article.Content.Excerpt.MatchingPodium as Podium
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Core.Mod.Html.Url (absolutizeOurObjectStorageUrls, relativizeCleanOurUrls)

buildContent :: QueryPayload.Need ContentOpt ContentInnerNeeds -> Content -> QueryResult.Return Content
buildContent QueryPayload.NotNeeded _ = QueryResult.NotGivenBecauseNotNeeded
buildContent (QueryPayload.Needed { excerpt, untagHtml } _) content = QueryResult.Given $
  let
    treatUrls h = relativizeCleanOurUrls $ absolutizeOurObjectStorageUrls h
    excerptFallback fallbackNewlineReplacement = treatUrls $ ContentExcerpt.excerpt content untagHtml fallbackNewlineReplacement ContentExcerpt.defaultCutStrategy
  in
    case excerpt of
      YesBestMatchingWords { newlineReplacement, words } | Array.length words > 0 ->
        case Podium.podiumExcerpt words content untagHtml newlineReplacement of
          Just podium -> treatUrls podium
          Nothing -> excerptFallback newlineReplacement
      YesBestMatchingWords { newlineReplacement } -> excerptFallback newlineReplacement
      Yes { newlineReplacement } -> excerptFallback newlineReplacement
      No { newlineReplacement } -> treatUrls (ContentExcerpt.cleanHtml untagHtml newlineReplacement content)
