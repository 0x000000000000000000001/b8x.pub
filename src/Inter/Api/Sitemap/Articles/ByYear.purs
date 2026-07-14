module Inter.Api.Sitemap.Articles.ByYear where

import Proem

import Config.PublicConfig (publicConfig, toAbsolute_)
import Core.Feat.Sitemap.Message.Query.ListYearArticles.ListYearArticles (listYearArticles)
import Core.Mod.Time.Instant (toIsoString)
import Core.Mod.Time.Year (Year)
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

handleSitemapArticlesByYear :: Year -> Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleSitemapArticlesByYear y ctx _ res = do
  runId <- ʌ Id.generate
  let cause = { run: runId, append: Nothing, cause: Nothing, overriddenAt: Nothing }

  resEither <- runApiM ctx cause (listYearArticles { year: y })

  case resEither of
    Right { articles } -> do
      let
        xslUrl = toAbsolute_ publicConfig.api.host (print ApiRoute.routeCodec ApiRoute.SitemapXsl) <> "?v=3"
        xmlHeader = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<?xml-stylesheet type=\"text/xsl\" href=\"" <> xslUrl <> "\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\">\n"
        xmlFooter = "</urlset>"

        makeUrl r =
          let
            routeParams =
              { menu:
                  { search: { openWith: Nothing, withAuthorFilter: Nothing }
                  , magazineIssueOpen: Nothing
                  }
              , consumeMagicLoginToken: Nothing
              }
            path = Navigate.routePath (Navigate.Article r.slug routeParams)
            loc = toAbsolute_ publicConfig.ui.host path
          in
            "  <url>\n"
              <> "    <loc>"
              <> loc
              <> "</loc>\n"
              <> "    <lastmod>"
              <> toIsoString r.seo.updatedAt
              <> "</lastmod>\n"
              <> "  </url>\n"

        body = xmlHeader <> String.joinWith "" (makeUrl <$> articles) <> xmlFooter

      sendXml res 200 body

    Left _ ->
      sendXml res 500 "<?xml version=\"1.0\" encoding=\"UTF-8\"?><error>Internal Server Error</error>"
