module Infra.Client.Sendy where

import Proem

import Affjax (defaultRequest, printError)
import Affjax.RequestBody (formURLEncoded)
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Config.InternalConfig (SendyConfig)
import Control.Monad.Error.Class (throwError)
import Data.Either (Either(..))
import Data.FormURLEncoded (FormURLEncoded)
import Data.FormURLEncoded as FormURLEncoded
import Util.Type.String.ToString (toString)
import Core.Mod.Email.Email (Email)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..), isJust)
import Data.Tuple (Tuple(..))
import Effect.Aff.Class (class MonadAff)
import Effect.Exception (error)
import Run (AFF, EFFECT, Run)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))
import Util.Http.Http (request)

type Config = Maybe SendyConfig

type READER_SENDY_CONFIG fx = (readerSendyConfig :: Reader Config | fx)

readerSendyConfig' = π :: Π "readerSendyConfig"

runSendyConfigReader :: ∀ fx a. Config -> Run (READER_SENDY_CONFIG + fx) a -> Run fx a
runSendyConfigReader = runReaderAt readerSendyConfig'

createConfig :: ∀ m. MonadAff m => SendyConfig -> m Config
createConfig config = η $ Just config

createTestConfig :: ∀ m. MonadAff m => m Config
createTestConfig = η $ Nothing

askConfig :: ∀ fx. Run (READER_SENDY_CONFIG + EFFECT + AFF + fx) Config
askConfig = askAt readerSendyConfig'

type CreateCampaignPayload =
  { title :: String
  , subject :: String
  , htmlText :: String
  , sendRightaway :: Boolean
  , scheduledFor :: Maybe String
  }

createCampaign
  :: ∀ fx
   . CreateCampaignPayload
  -> Run (READER_SENDY_CONFIG + EFFECT + AFF + fx) Ɩ
createCampaign payload =
  sendRequest
    "api/campaigns/create.php"
    (makeCampaignPayload payload)
    isCampaignSuccess
    "Sendy API Error"

makeCampaignPayload :: CreateCampaignPayload -> SendyConfig -> FormURLEncoded
makeCampaignPayload payload config =
  FormURLEncoded.fromArray
    [ Tuple "api_key" (Just config.apiKey)
    , Tuple "from_name" (Just "Books")
    , Tuple "from_email" (Just "noreply@newsletter.books.fr")
    , Tuple "reply_to" (Just "noreply@newsletter.books.fr")
    , Tuple "title" (Just payload.title)
    , Tuple "subject" (Just payload.subject)
    , Tuple "html_text" (Just payload.htmlText)
    , Tuple "send_campaign" (Just (if payload.sendRightaway || isJust payload.scheduledFor then "1" else "0"))
    , Tuple "brand_id" (Just config.brandId)
    , Tuple "list_ids" (Just config.listId)
    ] <> (case payload.scheduledFor of
            Just date -> FormURLEncoded.fromArray [Tuple "schedule_date_time" (Just date), Tuple "schedule_timezone" (Just "Europe/Paris")]
            Nothing -> FormURLEncoded.fromArray [])

isCampaignSuccess :: String -> Boolean
isCampaignSuccess = case _ of
  "Campaign created" -> true
  "Campaign saved" -> true
  "Campaign draft saved" -> true
  _ -> false

addSubscriber
  :: ∀ fx
   . Email
  -> Run (READER_SENDY_CONFIG + EFFECT + AFF + fx) Ɩ
addSubscriber email =
  sendRequest
    "subscribe"
    (makeSubscribePayload email)
    isSubscribeSuccess
    "Sendy API Subscribe Error"

makeSubscribePayload :: Email -> SendyConfig -> FormURLEncoded
makeSubscribePayload email config =
  FormURLEncoded.fromArray
    [ Tuple "api_key" (Just config.apiKey)
    , Tuple "list" (Just config.listId)
    , Tuple "email" (Just $ toString email)
    , Tuple "boolean" (Just "true")
    , Tuple "gdpr" (Just "true")
    ]

isSubscribeSuccess :: String -> Boolean
isSubscribeSuccess = case _ of
  "1" -> true
  "Already subscribed." -> true
  _ -> false

sendRequest
  :: ∀ fx
   . String
  -> (SendyConfig -> FormURLEncoded)
  -> (String -> Boolean)
  -> String
  -> Run (READER_SENDY_CONFIG + EFFECT + AFF + fx) Ɩ
sendRequest endpointSuffix makePayload isSuccessBody errorPrefix = do
  config <- askConfig

  case config of
    Nothing -> ηι
    Just config_ -> do
      let
        endpointUrl = "https://" <> config_.host <> "/" <> endpointSuffix

        req =
          defaultRequest
            { url = endpointUrl
            , method = Left POST
            , content = Just $ formURLEncoded (makePayload config_)
            , responseFormat = ResponseFormat.string
            }

      resEither <- ʌ' $ request req

      case resEither of
        Left err -> ʌ' $ throwError $ error $ "Sendy (" <> endpointUrl <> "): " <> printError err
        Right res -> do
          let (StatusCode code) = res.status

          if code >= 200 && code < 300 then
            if isSuccessBody res.body then
              ηι
            else
              ʌ' $ throwError $ error $ errorPrefix <> " (" <> endpointUrl <> ") (body): " <> res.body
          else ʌ' $ throwError $ error $ errorPrefix <> " (" <> endpointUrl <> ") " <> show code
