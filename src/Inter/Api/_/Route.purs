module Inter.Api.Route where

import Proem hiding ((/))

import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Routing.Duplex (RouteDuplex', optional, params, root, segment, string)
import Routing.Duplex.Generic (noArgs, sum)
import Routing.Duplex.Generic.Syntax ((/))
import Core.Mod.Time.Year (Year)
import Core.Mod.Time.Year.Inter.Api.Route.Codec (yearCodec)

data Route
  = Ping
  | WebhookHelloAsso { secret :: Maybe String }
  | AuthMagicLinkRequest
  | AuthVerifyMagicLink
  | AuthRefresh
  | AuthLogout
  | SocialMeta { path :: String, agent :: Maybe String }
  | SocialWatermark { url :: Maybe String, agent :: Maybe String, v :: Maybe String }
  | SitemapIndex
  | SitemapArticlesIndex
  | SitemapArticlesByYear Year
  | SitemapMagazineIssues
  | SitemapXsl
  | Write String
  | Read String

derive instance Generic Route _

routeCodec :: RouteDuplex' Route
routeCodec = root $ sum
  { "Ping": "ping" / noArgs
  , "WebhookHelloAsso": "webhook" / "helloasso" / params { secret: optional ◁ string }
  , "AuthMagicLinkRequest": "auth" / "magic-link" / "send" / noArgs
  , "AuthVerifyMagicLink": "auth" / "magic-link" / "consume" / noArgs
  , "AuthRefresh": "auth" / "refresh" / noArgs
  , "AuthLogout": "auth" / "logout" / noArgs
  , "SocialMeta": "social" / "meta" / params { path: string, agent: optional ◁ string }
  , "SocialWatermark": "social" / "watermark" / params { url: optional ◁ string, agent: optional ◁ string, v: optional ◁ string }
  , "SitemapIndex": "sitemap" / "index.xml" / noArgs
  , "SitemapArticlesIndex": "sitemap" / "articles" / "index.xml" / noArgs
  , "SitemapArticlesByYear": "sitemap" / "articles" / (yearCodec ".xml")
  , "SitemapMagazineIssues": "sitemap" / "magazine-issues.xml" / noArgs
  , "SitemapXsl": "sitemap.xsl" / noArgs
  , "Write": "write" / segment
  , "Read": "read" / segment
  }
