module Inter.Ui.Main (main) where

import Util.Foreign.Native as Util.Foreign.Native
import Control.Monad.Except as Control.Monad.Except
import Proem hiding (div)

import Config.PublicConfig (publicConfig)
import Data.DateTime.Instant (toDateTime)
import Data.Either (Either(..), hush)
import Data.Formatter.DateTime (formatDateTime)
import Effect (Effect)
import Data.Maybe (Maybe(..))
import Effect.Aff (launchAff_, try)
import Effect.Class.Console as Console
import Effect.Now (now)
import Halogen (hoist, mkTell)
import Halogen.Subscription as HS
import Halogen.Aff (awaitBody, runHalogenAff)
import Halogen.VDom.Driver (runUI)
import Inter.Ui.Capability.Navigate.Navigate as Navigate
import Inter.Ui.Router.Component as RouterComponent
import Inter.Ui.Router.Type as RouterType
import Inter.Ui.UiM (runUiM)
import Routing.Duplex (parse)
import Routing.PushState (makeInterface)
import Util.Env (Env(..))
import Data.String (Pattern(..), stripSuffix)
import Inter.Ui.Api.Auth (requestMagicLink, apiRegisterUser)
import Inter.Ui.AuthGlobal (_exposeAuth, isLoggedIn)
import Inter.Ui.Store.Store as GlobalStore
import Inter.Ui.Api.Membership (apiGetUserAccount)
import Core.Mod.User.Id.Message.Field.TargetUser (TargetUser(..))
import Core.Feat.Membership.Message.Query.GetUserAccount.Field.Needs (Needs(..))
import Core.Message.Query.Payload (Need(..))
import Core.Message.Query.Result as QueryResult
import Network.RemoteData (RemoteData(..))

import Foreign.Object as Object
import Effect.Ref as Ref
import Util.BroadcastChannel.BroadcastChannel as BC
import Yoga.JSON (readImpl)
import Util.Type.String.ToString (toString)

main :: Effect Ɩ
main = do
  currentTime <- now

  let
    dateTime = toDateTime currentTime
    formattedDateTime = formatDateTime "HH:mm:ss.SSS" dateTime
    errorMessage = "Unable to parse loading date."

  when (publicConfig.env /= Dev) $ do
    Console.log $ "Version: " <> publicConfig.version
    Console.log $ "Loaded @ " <> formattedDateTime ?!⇽ (κ errorMessage)

  nav <- makeInterface
  articleCacheRef <- ʌ $ Ref.new { queue: [], map: Object.empty }
  apiCacheRef <- ʌ $ Ref.new { queue: [], map: Object.empty }
  { emitter: toastEmitter, listener: toastListener } <- ʌ HS.create
  { emitter: modalEmitter, listener: modalListener } <- ʌ HS.create
  isLoggedInVal <- ʌ $ isLoggedIn
  storeRef <- ʌ $ Ref.new { me: Nothing }
  { emitter: storeEmitter, listener: storeListener } <- ʌ HS.create

  _ <- ʌ $ HS.subscribe storeEmitter \newStore -> do
    Console.log $ "Global State 'me' changed: " <> case newStore.me of
      Nothing -> "Nothing"
      Just me -> "Just { email: " <> toString me.email <> ", adFree: " <> show me.membership.adFree <> ", hasPaidLastYear: " <> show me.membership.hasPaidLastYear <> " }"

  authChannel <- ʌ $ BC.make "auth_channel"
  ʌ $ BC.onMessage authChannel \msg -> do
    Console.log $ "Auth event received from another tab: " <> msg
    case hush (Util.Foreign.Native.parseJSON msg) >>= (hush ◁ Control.Monad.Except.runExcept ◁ readImpl) of
      Just (me :: Maybe GlobalStore.Me) -> do
        store <- Ref.read storeRef
        let newStore = store { me = me }
        Ref.write newStore storeRef
        HS.notify storeListener newStore
      Nothing -> pure unit

  let broadcastAuth msg = BC.postMessage authChannel msg

  let ctx = { articleCacheRef, apiCacheRef, toastListener, modalListener, storeRef, storeListener, storeEmitter, broadcastAuth }

  runHalogenAff do
    when isLoggedInVal $ ʌ $ launchAff_ $ do
      let payload = { user: Me, needs: Needs { adFree: Needed ι ι, hasPaidLastYear: Needed ι ι } }
      resEither <- try $ runUiM ctx $ apiGetUserAccount payload
      case resEither of
        Right (Success { email, adFree: QueryResult.Given adFree, hasPaidLastYear: QueryResult.Given hasPaidLastYear }) -> do
          ʌ $ Ref.modify_ (\s -> s { me = Just { email, membership: { adFree, hasPaidLastYear } } }) storeRef
          newStore <- ʌ $ Ref.read storeRef
          ʌ $ HS.notify storeListener newStore
        _ -> η unit

    _ <- ʌ $ _exposeAuth
      (\email -> launchAff_ $ void $ runUiM ctx $ requestMagicLink email)
      (\email -> launchAff_ $ void $ runUiM ctx $ apiRegisterUser email)

    body <- awaitBody
    io <- runUI (hoist (runUiM ctx) RouterComponent.component) { toastEmitter, modalEmitter } body

    let normalizePathname p = p == "/" ? p ↔ (stripSuffix (Pattern "/") p ??⇒ p)

    -- Listen for route changes FIRST, so we don't miss any redirects triggered during initial mount
    ø $ ʌ $ nav.listen \loc -> launchAff_ $ do
      case parse Navigate.routeCodec (normalizePathname loc.pathname <> loc.search) of
        Right route -> ø $ io.query $ mkTell $ RouterType.Navigate route
        Left _ -> ø $ io.query $ mkTell $ RouterType.Navigate Navigate.NotFound

    -- Navigate to initial route
    initialLoc <- ʌ nav.locationState
    case parse Navigate.routeCodec (normalizePathname initialLoc.pathname <> initialLoc.search) of
      Right route -> ø $ io.query $ mkTell $ RouterType.Navigate route
      Left _ -> ø $ io.query $ mkTell $ RouterType.Navigate Navigate.NotFound
