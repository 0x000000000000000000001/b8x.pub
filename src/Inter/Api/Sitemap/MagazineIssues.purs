module Inter.Api.Sitemap.MagazineIssues where

import Proem

import Config.PublicConfig (publicConfig, toAbsolute_)
import Core.Feat.Sitemap.Message.Query.ListMagazineIssues.ListMagazineIssues (listMagazineIssues)
import Core.Mod.Time.Instant (toIsoString)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String as String
import Effect.Aff (Aff)
import Inter.Api.ApiM (Context, runApiM)
import Inter.Ui.Capability.Navigate.Navigate as Navigate
import Core.Mod.Id.Id as Id
import Inter.Api.Sitemap.Xml (sendXml)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse)
import Inter.Api.Route as ApiRoute
import Routing.Duplex (print)


handleSitemapMagazineIssues :: Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleSitemapMagazineIssues ctx _ res = do
  runId <- ʌ Id.generate
  let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }

  resEither <- runApiM ctx cause (listMagazineIssues {})

  case resEither of
    Right { magazineIssues } -> do
      let
        xslUrl = toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec ApiRoute.SitemapXsl) <> "?v=3"
        xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"" <> xslUrl <> "\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
        xmlFooter = "</urlset>"

        makeUrl r =
          let
            lastModStr = "    <lastmod>" <> toIsoString r.seo.updatedAt <> "</lastmod>\n"
            routeParams =
              { menu:
                  { search: { openWith: Nothing, withAuthorFilter: Nothing }
                  , magazineIssueOpen: Just r.slug
                  }
              , consumeMagicLoginToken: Nothing
              }
            path = Navigate.routePath (Navigate.Home routeParams)
            loc = toAbsolute_ publicConfig.ui.host path
          in
            "  <url>\n"
              <> "    <loc>"
              <> loc
              <> "</loc>\n"
              <> lastModStr
              <> "  </url>\n"

        body = xmlHeader <> String.joinWith "" (makeUrl <$> magazineIssues) <> xmlFooter

      sendXml res 200 body

    Left _ ->
      sendXml res 500 "<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>Internal Server Error</error>"
