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
import Core.Feat.Review.Message.Query.SearchArticles.Query (SearchArticles(..))
import Core.Feat.Review.Message.Query.SearchArticles.Field.Needs as SearchArticlesNeeds
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result (Return(..))
import Inter.Api.Route as ApiRoute
import Routing.Duplex (print)
import Core.Mod.Projection.Finder.Sort (by, SortDirection(..))
import Data.Either (Either(..))
import Data.Array as Array
import Core.Mod.Time.Instant (toIsoString)
import Data.Maybe (Maybe(..))

handleSitemapIndex :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleSitemapIndex ctx _ res = do
  runId <- ʌ Id.generate
  let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }

  resArticles <- runApiM ctx cause $ Query.handleWithCache $ SearchArticles
    { sort: [ by @"writtenAt.instant" Desc ]
    , filter: Nothing
    , expectation: QuickNothingBetterThanSlowerSomething
    , limit: BoundedLimit 1
    , after: Nothing
    , needs: SearchArticlesNeeds.defaultNeeds { seoUpdatedAt = Needed ι ι }
    }

  resMagazines <- runApiM ctx cause $ Query.handleWithCache $ SearchMagazineIssues
    { sort: [ by @"seo.updatedAt" Desc ]
    , filter: Nothing
    , expectation: QuickNothingBetterThanSlowerSomething
    , limit: BoundedLimit 1
    , after: Nothing
    , needs: SearchMagazineIssuesNeeds.defaultNeeds { seoUpdatedAt = Needed ι ι }
    }

  let 
    articlesLastMod = case resArticles of
      Right { articles } -> case Array.head articles of
        Just a -> case a.seoUpdatedAt of
          Given u -> "    <lastmod>" <> toIsoString u <> "</lastmod>\n"
          _ -> ""
        Nothing -> ""
      Left _ -> ""

    magazinesLastMod = case resMagazines of
      Right { magazineIssues } -> case Array.head magazineIssues of
        Just m -> case m.seoUpdatedAt of
          Given u -> "    <lastmod>" <> toIsoString u <> "</lastmod>\n"
          _ -> ""
        Nothing -> ""
      Left _ -> ""

  let
    xslUrl = toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec ApiRoute.SitemapXsl) <> "?v=" <> show sitemapXslVersion
    xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"" <> xslUrl <> "\"?>\n<sitemapindex xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
    xmlFooter = "</sitemapindex>"

    makeUrls =
      "  <sitemap>\n"
        <> "    <loc>"
        <> toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec ApiRoute.SitemapArticlesIndex)
        <> "</loc>\n"
        <> articlesLastMod
        <> "  </sitemap>\n"
        <> "  <sitemap>\n"
        <> "    <loc>"
        <> toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec ApiRoute.SitemapMagazineIssues)
        <> "</loc>\n"
        <> magazinesLastMod
        <> "  </sitemap>\n"

    body = xmlHeader <> makeUrls <> xmlFooter

  sendXml res 200 body
