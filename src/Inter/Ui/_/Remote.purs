module Inter.Ui.Remote
  ( class FromRemoteOutput
  , fromRemoteOutput
  , queryModify
  , queryModify'
  , queryUpdateMeta
  , query
  , query_
  , commandModify
  , commandModify'
  , command
  , command_
  , getCsrfToken
  ) where

import Proem

import Affjax (printError)
import Affjax as Affjax
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Affjax.ResponseHeader (ResponseHeader(..))
import Affjax.StatusCode (StatusCode(..))
import Control.Monad.Trans.Class (class MonadTrans)
import Core.Message.Command.Command (class IsCommand)
import Core.Message.Query.Query (class IsQuery)
import Foreign (Foreign)
import Yoga.JSON (class ReadForeign, readImpl, writeImpl, writeJSON, readJSON)
import Control.Monad.Except (runExcept)
import Promise.Aff (Promise, fromAff, toAff)
import Promise as Promise
import Data.Array as Array
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Lens (Lens', (.~), (^.))
import Data.Maybe (Maybe(..))
import Data.String (toLower)
import Effect (Effect)
import Effect.Aff (Aff, Milliseconds(..), delay)
import Effect.Aff.Class (class MonadAff)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Effect.Unsafe (unsafePerformEffect)
import Halogen (HalogenM, modify_)
import Inter.Api.Social.Meta.Type (Meta)
import Inter.Api.Whitelist.Command (CommandRow)
import Inter.Api.Whitelist.Query (QueryRow)
import Inter.Ui.Capability.ApiCache.Trans as ApiCache
import Inter.Ui.Capability.Log.Trans (error)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Capability.Navigate.Trans (navigate, updateMeta)
import Inter.Ui.Type.Remote (Remote)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Capability.Toast.Trans (toast)
import Inter.Ui.Type.Toast (ToastType(Info))
import Network.RemoteData (RemoteData(..))
import Util.Aff (ʌ')
import Util.Http.Http as Http
import Util.Type.Row.Row (class InRow)
import Util.Type.String.String (caseToKebab)
import Util.Type.Type (reflectName)
import Config.PublicConfig (publicConfig)

foreign import getCsrfToken :: Effect String
foreign import runWithWebLockImpl :: ∀ a. Effect (Promise a) -> Effect (Promise a)

runWithWebLock :: ∀ a. Promise.Flatten a a => Aff a -> Aff a
runWithWebLock action = toAff =<< liftEffect (runWithWebLockImpl (fromAff action))

refreshLockRef :: Ref.Ref Boolean
refreshLockRef = unsafePerformEffect (Ref.new false)

acquireLock :: Aff Unit
acquireLock = do
  acquired <- liftEffect do
    isLocked <- Ref.read refreshLockRef
    if isLocked then pure false
    else do
      Ref.write true refreshLockRef
      pure true
  if acquired then pure unit
  else do
    delay $ Milliseconds 50.0
    acquireLock

releaseLock :: Aff Unit
releaseLock = liftEffect $ Ref.write false refreshLockRef

queryModify
  :: ∀ state action slots output query state_ fields_ payload_ a
   . IsQuery query state_ fields_ payload_ a
  => InRow query QueryRow
  => FromRemoteOutput a
  => (Remote a -> HalogenM state action slots output UiM Ɩ)
  -> Lens' state (Remote a)
  -> query
  -> HalogenM state action slots output UiM (Remote a)
queryModify onResult = queryModify' identity onResult

queryModify'
  :: ∀ state action slots output query state_ fields_ payload_ a b
   . IsQuery query state_ fields_ payload_ a
  => InRow query QueryRow
  => FromRemoteOutput a
  => (a -> b)
  -> (Remote b -> HalogenM state action slots output UiM Ɩ)
  -> Lens' state (Remote b)
  -> query
  -> HalogenM state action slots output UiM (Remote a)
queryModify' modifyData onResult lens query' = do
  let
    queryName = reflectName @query
    url = "/api/read/" <> (queryName # caseToKebab)

  mCached <- ApiCache.getApiCache url query'

  case mCached of
    Just { data: cachedData } -> do
      case decodePayload cachedData of
        Right data' -> do
          let remote = Success (modifyData data')
          modify_ (_ # lens .~ remote)
          onResult remote
        Left _ -> modify_ $ lens .~ Loading
    Nothing -> do
      modify_ $ lens .~ Loading

  res <- query query'

  let remoteRes = modifyData <$> res
  modify_ (_ # lens .~ remoteRes)
  onResult remoteRes

  η res

queryUpdateMeta
  :: ∀ state action slots output query state_ fields_ payload_ a
   . IsQuery query state_ fields_ payload_ a
  => InRow query QueryRow
  => FromRemoteOutput a
  => (a -> Maybe Meta)
  -> query
  -> HalogenM state action slots output UiM Ɩ
queryUpdateMeta buildMeta query' = do
  res <- query query'

  case res of
    Success data_ -> updateMeta (buildMeta data_)
    _ -> η ι

query
  :: ∀ t query state_ fields_ payload_ a
   . IsQuery query state_ fields_ payload_ a
  => InRow query QueryRow
  => FromRemoteOutput a
  => MonadTrans t
  => MonadAff (t UiM)
  => query
  -> t UiM (Remote a)
query query' =
  let
    queryName = reflectName @query
    url = "/api/read/" <> (queryName # caseToKebab)
  in
    performRequest true url (writeImpl query')

query_
  :: ∀ t query state_ fields_ payload_ a
   . IsQuery query state_ fields_ payload_ a
  => InRow query QueryRow
  => FromRemoteOutput a
  => MonadTrans t
  => MonadAff (t UiM)
  => query
  -> t UiM Unit
query_ = ø ◁ query

commandModify
  :: ∀ state action slots output cmd state_ fields_ payload_ a
   . IsCommand cmd state_ fields_ payload_ a
  => InRow cmd CommandRow
  => FromRemoteOutput a
  => Lens' state (Remote a)
  -> cmd
  -> HalogenM state action slots output UiM (Remote a)
commandModify = commandModify' identity

commandModify'
  :: ∀ state action slots output cmd state_ fields_ payload_ a b
   . IsCommand cmd state_ fields_ payload_ a
  => InRow cmd CommandRow
  => FromRemoteOutput a
  => (a -> b)
  -> Lens' state (Remote b)
  -> cmd
  -> HalogenM state action slots output UiM (Remote a)
commandModify' modifyData lens cmd' = do
  let
    setLoadingIfNeeded st = case st ^. lens of
      Success _ -> st
      Loading -> st
      _ -> st # lens .~ Loading

  modify_ setLoadingIfNeeded

  res <- command cmd'

  modify_ (_ # lens .~ (modifyData <$> res))

  η res

command
  :: ∀ t cmd state_ fields_ payload_ a
   . IsCommand cmd state_ fields_ payload_ a
  => InRow cmd CommandRow
  => FromRemoteOutput a
  => MonadTrans t
  => MonadAff (t UiM)
  => cmd
  -> t UiM (Remote a)
command cmd' = do
  let
    commandName = reflectName @cmd
    url = "/api/write/" <> (commandName # caseToKebab)

  performRequest false url (writeImpl cmd')

command_
  :: ∀ t cmd state_ fields_ payload_ a
   . IsCommand cmd state_ fields_ payload_ a
  => InRow cmd CommandRow
  => FromRemoteOutput a
  => MonadTrans t
  => MonadAff (t UiM)
  => cmd
  -> t UiM Unit
command_ = ø ◁ command

performRequest
  :: ∀ t a
   . FromRemoteOutput a
  => MonadTrans t
  => MonadAff (t UiM)
  => Boolean
  -> String
  -> Foreign
  -> t UiM (Remote a)
performRequest useCache url payload = go 4
  where
  go retriesLeft = do
    mCached <- if useCache then ApiCache.getApiCache url payload else η Nothing
    request <- buildRequest mCached url payload
    res <- ʌ' $ Http.request request

    case res of
      Left err -> do
        error $ "Error fetching API " <> url <> ": " <> printError err
        η $ Failure (printError err)
      Right response -> handleResponse mCached retriesLeft response

  handleResponse mCached retriesLeft response = do
    let (StatusCode code) = response.status
    if code == 304 then
      handle304 url mCached
    else if code >= 500 && retriesLeft > 0 then
      retryWithDelay retriesLeft
    else if code >= 200 && code < 400 then
      handle2xx useCache url payload response
    else if code == 401 && retriesLeft > 0 then
      handle401 retriesLeft
    else
      η $ Failure ("HTTP " <> show code <> ": " <> response.statusText)

  retryWithDelay retriesLeft = do
    ʌ' $ delay $ Milliseconds 250.0
    go (retriesLeft - 1)

  handle401 retriesLeft = do
    attemptTokenRefresh
    go (retriesLeft - 1)

buildRequest
  :: ∀ t
   . MonadTrans t
  => MonadAff (t UiM)
  => Maybe { etag :: String, data :: Foreign }
  -> String
  -> Foreign
  -> t UiM (Affjax.Request String)
buildRequest mCached url payload = do
  csrfToken <- ʌ' $ liftEffect getCsrfToken
  let
    cacheHeaders = case mCached of
      Just { etag } -> [ RequestHeader "If-None-Match" etag ]
      _ -> []

    appIdHeader = [ RequestHeader "X-App-Id" publicConfig.ui.appId ]

    headersWithCsrf = (if csrfToken /= "" then [ RequestHeader "X-Csrf-Token" csrfToken ] else []) <> cacheHeaders <> appIdHeader

  η $ Affjax.defaultRequest
    { url = url
    , method = Left POST
    , content = Just $ RequestBody.string (writeJSON payload)
    , responseFormat = ResponseFormat.string
    , headers = headersWithCsrf
    , withCredentials = true
    }

handle304 :: ∀ t a. MonadTrans t => MonadAff (t UiM) => FromRemoteOutput a => String -> Maybe { etag :: String, data :: Foreign } -> t UiM (Remote a)
handle304 url mCached = case mCached of
  Just { data: cachedData } -> case decodePayload cachedData of
    Right data' -> η $ Success data'
    Left err -> do
      error $ "Error decoding cached API " <> url <> ": " <> err
      η $ Failure err
  Nothing -> do
    error $ "Received 304 but no cache found for " <> url
    η $ Failure "Received 304 but no cache found"

handle2xx :: ∀ t a. MonadTrans t => MonadAff (t UiM) => FromRemoteOutput a => Boolean -> String -> Foreign -> Affjax.Response String -> t UiM (Remote a)
handle2xx useCache url payload response = do
  let
    bodyForeign = case readJSON response.body of
      Right (f :: Foreign) -> f
      Left _ -> payload -- Fallback dummy, decodePayload will fail anyway if invalid json

  when useCache do
    let etagM = Array.findMap (\(ResponseHeader k v) -> if toLower k == "etag" then Just v else Nothing) response.headers
    case etagM of
      Just etag -> ApiCache.putApiCache url payload { etag, data: bodyForeign }
      Nothing -> η ι

  case decodePayload bodyForeign of
    Right data' -> η $ Success data'
    Left err -> do
      error $ "Error fetching API " <> url <> ": " <> err
      η $ Failure err

attemptTokenRefresh :: ∀ t. MonadTrans t => MonadAff (t UiM) => t UiM Ɩ
attemptTokenRefresh = do
  oldCsrfToken <- ʌ' $ liftEffect getCsrfToken
  refreshRes <- ʌ' $ runWithWebLock do
    acquireLock
    newCsrfToken <- liftEffect getCsrfToken

    if oldCsrfToken /= newCsrfToken && newCsrfToken /= "" then do
      -- The session cookie is httpOnly, so we can't read it directly to know if it was refreshed.
      -- However, since the backend generates a new CSRF token bijectively along with every new session token,
      -- we can use the CSRF token (which is NOT httpOnly) as an observable proxy for the session token.
      --
      -- If the CSRF token has changed while we were waiting for the lock, it means another request 
      -- (either from this tab or another tab) has ALREADY performed the refresh.
      -- Therefore, we don't need to trigger another refresh. We just return a fake success 
      -- and let the original request retry with the newly updated cookies.
      releaseLock
      pure $ Right { status: StatusCode 200, statusText: "OK", headers: [], body: unit }
    else do
      let
        refreshRequest = Affjax.defaultRequest
          { url = "/api/auth/refresh"
          , method = Left POST
          , content = Nothing
          , responseFormat = ResponseFormat.ignore
          , headers = (if newCsrfToken /= "" then [ RequestHeader "X-Csrf-Token" newCsrfToken ] else []) <> [ RequestHeader "X-App-Id" publicConfig.ui.appId ]
          , withCredentials = true
          }
      res <- Http.request refreshRequest
      releaseLock
      pure res

  case refreshRes of
    Right refreshResponse -> do
      let (StatusCode refreshCode) = refreshResponse.status
      if refreshCode >= 200 && refreshCode < 300 then pure ι
      else do
        toast { id: "auth-logout", message: "Vous avez été déconnecté(e)", tType: Info }
        let
          logoutRequest = Affjax.defaultRequest
            { url = "/api/auth/logout"
            , method = Left POST
            , content = Nothing
            , responseFormat = ResponseFormat.ignore
            , headers = [ RequestHeader "X-App-Id" publicConfig.ui.appId ]
            , withCredentials = true
            }
        _ <- ʌ' $ Http.request logoutRequest
        _ <- navigate (Home { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } })
        error $ "Token refresh failed with HTTP " <> show refreshCode
    Left refreshErr -> do
      toast { id: "auth-logout", message: "Vous avez été déconnecté(e)", tType: Info }
      let
        logoutRequest = Affjax.defaultRequest
          { url = "/api/auth/logout"
          , method = Left POST
          , content = Nothing
          , responseFormat = ResponseFormat.ignore
          , headers = [ RequestHeader "X-App-Id" publicConfig.ui.appId ]
          , withCredentials = true
          }
      _ <- ʌ' $ Http.request logoutRequest
      _ <- navigate (Home { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } })
      error $ "Error requesting token refresh: " <> printError refreshErr


class FromRemoteOutput a where
  fromRemoteOutput :: Foreign -> Either String a

instance FromRemoteOutput Unit where
  fromRemoteOutput _ = Right unit
else instance ReadForeign a => FromRemoteOutput a where
  fromRemoteOutput f = lmap show (runExcept (readImpl f))

decodePayload :: ∀ a. FromRemoteOutput a => Foreign -> Either String a
decodePayload json = do
  { success } <- lmap show $ runExcept (readImpl @{ success :: Boolean } json)

  if success then do
    { data: dataJson } <- lmap show $ runExcept (readImpl @{ data :: Foreign } json)
    fromRemoteOutput @a dataJson
  else do
    { error } <- lmap show $ runExcept (readImpl @{ error :: { message :: String } } json)
    Left error.message
