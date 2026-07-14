module Inter.Api.Sitemap.Articles.Index where

import Proem

import Config.PublicConfig (publicConfig, toAbsolute_)
import Data.String as String
import Effect.Aff (Aff)
import Inter.Api.ApiM (Context, runApiM)
import Inter.Api.Sitemap.Xml (sendXml)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse)
import Data.Array (range)
import Data.DateTime (date, year)
import Data.Enum (fromEnum)
import Effect.Now (nowDateTime)
import Core.Mod.Id.Id as Id
import Core.Feat.Sitemap.Message.Query.ListArticleYears.ListArticleYears (listArticleYears)
import Data.Either (Either(..))
import Data.Array as Array
import Core.Mod.Time.Instant (toIsoString)
import Data.Maybe (Maybe(..))
import Inter.Api.Route as ApiRoute
import Routing.Duplex (print)
import Core.Mod.Time.Year as Year

handleSitemapArticlesIndex :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleSitemapArticlesIndex ctx _ res = do
  runId <- ʌ Id.generate
  let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }
  
  dt <- ʌ nowDateTime
  
  let
    years = range 2009 (fromEnum $ year $ date dt)

  resArticleYears <- runApiM ctx cause (listArticleYears {})

  let 
    getYearUpdated yStr = case resArticleYears of
      Right { years: yearsResult } ->
        let 
           matches r = (show r.year) == yStr
        in case Array.find matches yearsResult of
          Just r -> "    <lastmod>" <> toIsoString r.seo.updatedAt <> "</lastmod>\n"
          Nothing -> ""
      Left _ -> ""

    makeUrl y =
      let
        yStr = show y
      in
        "  <sitemap>\n"
          <> "    <loc>"
          <> toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec (ApiRoute.SitemapArticlesByYear (Year.unsafeFromInt y)))
          <> "</loc>\n"
          <> getYearUpdated yStr
          <> "  </sitemap>\n"
          
    itemsHtml = makeUrl <$> years

  let
    xslUrl = toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec ApiRoute.SitemapXsl) <> "?v=3"
    xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"" <> xslUrl <> "\"?>\n<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
    xmlFooter = "</sitemapindex>"

    body = xmlHeader <> String.joinWith "" itemsHtml <> xmlFooter

  sendXml res 200 body
