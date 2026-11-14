module Inter.Api.Sitemap.Index where

import Proem

import Config.PublicConfig (publicConfig, toAbsolute_)
import Effect.Aff (Aff)
import Inter.Api.ApiM (Context, runApiM)
import Inter.Api.Sitemap.Xsl (sitemapXslVersion)
import Inter.Api.Sitemap.Xml (sendXml)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse)
import Core.Mod.Projection.Finder.BoundedLimit.BoundedLimit (BoundedLimit(..))
import Core.Mod.Id.Id as Id
import Core.Message.Query.Query as Query
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Query (SearchMagazineIssues(..))
import Core.Feat.Reference.Message.Query.SearchMagazineIssues.Field.Needs as SearchMagazineIssuesNeeds
import Core.Feat.Sitemap.Message.Query.ListArticleYears.ListArticleYears (listArticleYears)
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result (Return(..))
import Inter.Api.Route as ApiRoute
import Routing.Duplex (print)
import Core.Mod.Projection.Finder.Sort (by, SortDirection(..))
import Data.Either (Either(..))
import Data.Array as Array
import Core.Mod.Time.Instant (toIsoString)
import Data.Maybe (Maybe(..))
import Data.Array (range)
import Data.DateTime (date, year)
import Data.Enum (fromEnum)
import Effect.Now (nowDateTime)
import Core.Mod.Time.Year as Year
import Data.String as String

handleSitemapIndex :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleSitemapIndex ctx _ res = do
  runId <- ʌ Id.generate
  let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }

  dt <- ʌ nowDateTime
  
  let
    years = range 2009 (fromEnum $ year $ date dt)

  resArticleYears <- runApiM ctx cause (listArticleYears {})

  resMagazines <- runApiM ctx cause $ Query.handleWithCache $ SearchMagazineIssues
    { sort: [ by @"seo.updatedAt" Desc ]
    , filter: Nothing
    , expectation: QuickNothingBetterThanSlowerSomething
    , limit: BoundedLimit 1
    , after: Nothing
    , needs: SearchMagazineIssuesNeeds.defaultNeeds { seoUpdatedAt = Needed ι ι }
    }

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
          <> toAbsolute_ publicConfig.ui.host (print ApiRoute.routeCodec (ApiRoute.SitemapArticlesByYear (Year.unsafeFromInt y)))
          <> "</loc>\n"
          <> getYearUpdated yStr
          <> "  </sitemap>\n"
          
    articlesHtml = makeUrl <$> years

    magazinesLastMod = case resMagazines of
      Right { magazineIssues } -> case Array.head magazineIssues of
        Just m -> case m.seoUpdatedAt of
          Given u -> "    <lastmod>" <> toIsoString u <> "</lastmod>\n"
          _ -> ""
        Nothing -> ""
      Left _ -> ""

  let
    xslUrl = toAbsolute_ publicConfig.ui.host (print ApiRoute.routeCodec ApiRoute.SitemapXsl) <> "?v=" <> show sitemapXslVersion
    xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"" <> xslUrl <> "\"?>\n<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
    xmlFooter = "</sitemapindex>"

    magazinesUrl =
        "  <sitemap>\n"
        <> "    <loc>"
        <> toAbsolute_ publicConfig.ui.host (print ApiRoute.routeCodec ApiRoute.SitemapMagazineIssues)
        <> "</loc>\n"
        <> magazinesLastMod
        <> "  </sitemap>\n"

    body = xmlHeader <> String.joinWith "" articlesHtml <> magazinesUrl <> xmlFooter

  sendXml res 200 body
