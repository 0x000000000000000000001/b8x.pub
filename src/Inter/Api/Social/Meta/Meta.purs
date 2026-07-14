module Inter.Api.Social.Meta.Meta where

import Proem

import Config.PublicConfig (publicConfig, toAbsolute_)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String as String
import Effect.Aff (Aff)
import Inter.Api.ApiM (Context)
import Inter.Api.Route (Route(..), routeCodec) as ApiRoute
import Inter.Api.Social.Meta.Route.QueryIndex (queryMeta)
import Inter.Api.Social.Meta.Type (Meta, defaultDescription, defaultMeta, defaultTitle)
import Inter.Ui.Capability.Navigate.Navigate as UiRoute
import Node.Encoding (Encoding(..))
import Node.HTTP.OutgoingMessage (setHeader, toWriteable)
import Node.HTTP.ServerResponse (setStatusCode, toOutgoingMessage)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse)
import Node.Stream (end, writeString)
import Routing.Duplex (print, parse)

handleSocialMeta :: String -> Maybe String -> Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleSocialMeta path mAgent ctx _req res = do
  let
    normalizePathname p = p == "/" ? p ↔ (String.stripSuffix (String.Pattern "/") p ??⇒ p)
    normalizedPath = normalizePathname path

  case parse UiRoute.routeCodec normalizedPath of
    Right route -> do
      mHtmlMeta <- queryMeta ctx route
      case mHtmlMeta of
        Just htmlMeta -> sendHtml res 200 (buildMetaHtml publicConfig.ui.host normalizedPath mAgent htmlMeta)
        Nothing -> sendHtml res 404 "Not Found"
    Left _ ->
      sendHtml res 404 "Not Found"

buildMetaHtml :: String -> String -> Maybe String -> Meta -> String
buildMetaHtml uiHost path mAgent meta =
  let
    title = case meta.title of
      Just t -> t
      Nothing -> case defaultMeta.title of
        Just dt -> dt
        Nothing -> defaultTitle
    description = case meta.description of
      Just d -> d
      Nothing -> case defaultMeta.description of
        Just dd -> dd
        Nothing -> defaultDescription
  in
    fillTemplate
      title
      description
      (extractImageUrl uiHost mAgent meta.image)
      (toAbsolute_ uiHost path)
      uiHost

extractImageUrl :: String -> Maybe String -> Maybe String -> String
extractImageUrl uiHost mAgent mUrl =
  let
    watermarkUrl = toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec (ApiRoute.SocialWatermark { url: mUrl, agent: mAgent, v: Just watermarkCacheVersion }))
    defaultStaticUrl = toAbsolute_ uiHost "/asset/image/social.logo.jpg"
  in
    case mUrl of
      Just url | String.contains (String.Pattern "/social/watermark") url -> url
      Just _ -> watermarkUrl
      Nothing -> defaultStaticUrl

watermarkCacheVersion :: String
watermarkCacheVersion = "1"

fillTemplate :: String -> String -> String -> String -> String -> String
fillTemplate title description imageUrl articleUrl domain =
  socialTemplate
    # String.replaceAll (String.Pattern "{{TITLE}}") (String.Replacement (escapeHtml title))
    # String.replaceAll (String.Pattern "{{DESCRIPTION}}") (String.Replacement (escapeHtml description))
    # String.replaceAll (String.Pattern "{{IMAGE_URL}}") (String.Replacement imageUrl)
    # String.replaceAll (String.Pattern "{{URL}}") (String.Replacement articleUrl)
    # String.replaceAll (String.Pattern "{{DOMAIN}}") (String.Replacement domain)

socialTemplate :: String
socialTemplate =
  """
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <link rel="icon" type="image/png" href="https://{{DOMAIN}}/asset/image/favicon.png">
  <title>{{TITLE}}</title>
  <meta name="description" content="{{DESCRIPTION}}">
  <meta property="og:url" content="{{URL}}">
  <meta property="og:title" content="{{TITLE}}">
  <meta property="og:description" content="{{DESCRIPTION}}">
  <meta property="og:image" content="{{IMAGE_URL}}">
  <meta property="og:type" content="article">
  <meta name="twitter:card" content="summary_large_image">
  <meta property="twitter:domain" content="{{DOMAIN}}">
  <meta property="twitter:url" content="{{URL}}">
  <meta name="twitter:title" content="{{TITLE}}">
  <meta name="twitter:description" content="{{DESCRIPTION}}">
  <meta name="twitter:image" content="{{IMAGE_URL}}">
</head>
<body></body>
</html>
  """

sendHtml :: ServerResponse -> Int -> String -> Aff Ɩ
sendHtml res statusCode body = ʌ do
  setStatusCode statusCode res
  let msg = toOutgoingMessage res
  setHeader "Content-Type" "text/html; charset=utf-8" msg
  _ <- writeString (toWriteable msg) UTF8 body
  end (toWriteable msg)

escapeHtml :: String -> String
escapeHtml =
  String.replace (String.Pattern "\"") (String.Replacement "&quot;")
    ▷ String.replace (String.Pattern "<") (String.Replacement "&lt;")
    ▷ String.replace (String.Pattern ">") (String.Replacement "&gt;")