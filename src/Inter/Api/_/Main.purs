module Inter.Api.Main where

import Proem hiding ((/))

import Config.InternalConfig (internalConfig)
import Config.PublicConfig (publicConfig)
import Util.Env (Env(..))
import Data.Either (Either(..))
import Data.Int (toNumber)
import Data.Maybe (Maybe(..))
import Data.String as String
import Effect (Effect)
import Effect.Aff (Aff, delay, Milliseconds(..), forkAff, launchAff_, makeAff, nonCanceler)
import Effect.Console (log)
import Foreign.Object as Object
import Inter.Api.ApiM (Context)
import Inter.Api.ApiM as ApiM
import Inter.Api.Membership.Auth (handleRequestMagicLink, handleConsumeMagicLink, handleAuthRefresh, handleAuthLogout)
import Inter.Api.Ping (handlePing)
import Inter.Api.Registry as Registry
import Inter.Api.Route (Route(..), routeCodec)
import Inter.Api.Sitemap.Articles.ByYear (handleSitemapArticlesByYear)
import Inter.Api.Sitemap.Articles.Index (handleSitemapArticlesIndex)
import Inter.Api.Sitemap.Index (handleSitemapIndex)
import Inter.Api.Sitemap.MagazineIssues (handleSitemapMagazineIssues)
import Inter.Api.Sitemap.Xsl (handleSitemapXsl)
import Inter.Api.Social.Meta.Meta (handleSocialMeta)
import Inter.Api.Social.Watermark.Watermark (handleSocialWatermark)
import Inter.Api.Webhook.HelloAsso (handleWebhookHelloAsso)
import Inter.Cli.Util.Exit (exitSuccess)
import Node.Encoding (Encoding(..))
import Node.EventEmitter (on_)
import Node.HTTP (createServer)
import Node.HTTP.IncomingMessage (method, url)
import Node.HTTP.OutgoingMessage (setHeader, toWriteable)
import Node.HTTP.Server (requestH, toNetServer)
import Node.HTTP.ServerResponse (setStatusCode, toOutgoingMessage)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse)
import Node.Net.Server (listenTcp, close, closeH)
import Node.Net.Types (Server)
import Node.Stream (end, writeString)
import Routing.Duplex (parse)
import Util.Ops.Ctl (updateService)
import Util.Signal (Signal(..), _onSignal)

handle :: Context -> IncomingMessage IMServer -> ServerResponse -> Effect Ɩ
handle ctx req res = do
  let
    rawUrl = url req

    method' = method req

    normalizeUrl :: String -> String
    normalizeUrl u = case String.indexOf (String.Pattern "?") u of
      Just i ->
        let
          { before, after } = String.splitAt i u

          path = before == "/" ? before ↔ (String.stripSuffix (String.Pattern "/") before ??⇒ before)
        in
          path <> after
      Nothing -> u == "/" ? u ↔ (String.stripSuffix (String.Pattern "/") u ??⇒ u)

    url' = normalizeUrl rawUrl
  log $ method' <> " " <> url'
  case parse routeCodec url' of
    Right (WebhookHelloAsso { secret: mSecret }) -> launchAff_ $ handleWebhookHelloAsso mSecret ctx req res
    Right Ping ->
      launchAff_ do
        result <- handlePing
        ʌ $ sendResponse 200 result res
    Right AuthMagicLinkRequest -> launchAff_ $ handleRequestMagicLink ctx req res
    Right AuthVerifyMagicLink -> launchAff_ $ handleConsumeMagicLink ctx req res
    Right AuthRefresh -> launchAff_ $ handleAuthRefresh ctx req res
    Right AuthLogout -> launchAff_ $ handleAuthLogout ctx req res
    Right (SocialMeta { path, agent: mAgent }) -> launchAff_ $ handleSocialMeta path mAgent ctx req res
    Right (SocialWatermark { url: mUrl, agent: mAgent, v: _ }) -> launchAff_ $ handleSocialWatermark mUrl mAgent ctx req res
    Right SitemapIndex -> launchAff_ $ handleSitemapIndex ctx req res
    Right SitemapArticlesIndex -> launchAff_ $ handleSitemapArticlesIndex ctx req res
    Right (SitemapArticlesByYear year) -> launchAff_ $ handleSitemapArticlesByYear year ctx req res
    Right SitemapMagazineIssues -> launchAff_ $ handleSitemapMagazineIssues ctx req res
    Right SitemapXsl -> launchAff_ $ handleSitemapXsl ctx req res
    Right (Read _) -> handleDynamicRoute url'
    Right (Write _) -> handleDynamicRoute url'
    Left _ -> handleDynamicRoute url'
  where
    handleDynamicRoute urlStr = case Object.lookup urlStr Registry.registry of
      Just handler -> launchAff_ $ handler ctx req res
      Nothing -> sendResponse 404 "Not found." res

sendResponse :: Int -> String -> ServerResponse -> Effect Ɩ
sendResponse statusCode body res = do
  setStatusCode statusCode res
  let
    msg = toOutgoingMessage res
  setHeader "Content-Type" "application/json" msg
  ø $ writeString (toWriteable msg) UTF8 body
  end (toWriteable msg)

closeServer :: ∀ a. Server a -> Aff Ɩ
closeServer server =
  makeAff \resolve -> do
    server # on_ closeH (resolve (Right ι))
    close server
    η nonCanceler

main :: Effect Unit
main = do
  launchAff_ do
    let
      timeout = 300
    ctx <- ApiM.acquire
    server <- ʌ createServer
    ʌ $ server # on_ requestH (handle ctx)
    let
      netServer = toNetServer server

      gracefulShutdown reason = do
        ʌ $ log $ reason <> " Auto-shutting down gracefully..."

        -- We wait 2 seconds before actually closing the server.
        -- This prevents 502 Bad Gateway errors during rolling updates (Proxy Lag).
        -- It gives Traefik/Docker Swarm (or their equivalent) enough time to update their internal
        -- routing tables to stop sending traffic to this dying container.
        delay $ Milliseconds 2000.0

        closeServer netServer

        delay $ Milliseconds 500.0

        ApiM.complete ctx

        delay $ Milliseconds 500.0

        exitSuccess

    when (publicConfig.env == Prod) $ ø
      $ forkAff do
          ʌ $ log $ "Starting the API... I will stop automatically in " <> show timeout <> " seconds."
          delay $ Milliseconds (toNumber timeout * 1000.0)
          ʌ $ log $ "Timeout reached (" <> show timeout <> " seconds). Requesting zero-downtime update..."
          updateService internalConfig.orch.services.api.name
          ʌ $ log $ "Waiting up to 2 minutes for the orchestrator to send SIGTERM (or alike)..."
          delay $ Milliseconds $ 2.0 * 60_000.0
          gracefulShutdown $ "No SIGTERM (or alike) received from the orchestrator. Self-interrupting..."

    ʌ $ _onSignal (show INT) (launchAff_ $ gracefulShutdown $ "\nReceived " <> show INT <> ".")
    ʌ $ _onSignal (show TERM) (launchAff_ $ gracefulShutdown $ "\nReceived " <> show TERM <> ".")
    ʌ $ _onSignal (show QUIT) (launchAff_ $ gracefulShutdown $ "\nReceived " <> show QUIT <> ".")

    ʌ
      $ listenTcp
          netServer
          { host: "0.0.0.0"
          , port: 80
          }
    ʌ $ log "Server now running..."
