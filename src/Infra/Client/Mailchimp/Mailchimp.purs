module Infra.Client.Mailchimp.Mailchimp where

import Proem
import Control.Monad.Except as Control.Monad.Except
import Yoga.JSON as Yoga.JSON

import Affjax (defaultRequest, printError)
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Config.InternalConfig (MailchimpConfig)
import Control.Monad.Error.Class (throwError)
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.Array (foldl)
import Data.Array (concatMap, index, filter) as Array
import Data.String (joinWith)
import Data.Tuple (Tuple(..))
import Core.Feat.Effect.Newsletter (PrefillArticle)
import Data.String.Regex (regex, replace) as Regex
import Data.String.Regex.Flags (global, ignoreCase) as RegexFlags
import Util.Type.String.String (toRobustHtmlRegexPattern)
import Effect.Aff.Class (class MonadAff)
import Effect.Exception (error)
import Run (AFF, EFFECT, Run)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))
import Util.Http.Http (request)
import Core.Mod.Newsletter.Id.Id (NewsletterId)

type Config = Maybe MailchimpConfig

type READER_MAILCHIMP_CONFIG fx = (readerMailchimpConfig :: Reader Config | fx)

readerMailchimpConfig' = π :: Π "readerMailchimpConfig"

runMailchimpConfigReader :: ∀ fx a. Config -> Run (READER_MAILCHIMP_CONFIG + fx) a -> Run fx a
runMailchimpConfigReader = runReaderAt readerMailchimpConfig'

createConfig :: ∀ m. MonadAff m => MailchimpConfig -> m Config
createConfig config = η $ Just config

createTestConfig :: ∀ m. MonadAff m => m Config
createTestConfig = η $ Nothing

askConfig :: ∀ fx. Run (READER_MAILCHIMP_CONFIG + EFFECT + AFF + fx) Config
askConfig = askAt readerMailchimpConfig'

sendRequest
  :: ∀ fx
   . Method
  -> String
  -> Maybe String
  -> Run (READER_MAILCHIMP_CONFIG + EFFECT + AFF + fx) String
sendRequest method endpoint mBody = do
  config <- askConfig
  case config of
    Nothing -> η ""
    Just config_ -> do
      let
        endpointUrl = "https://" <> config_.serverPrefix <> ".api.mailchimp.com/3.0/" <> endpoint
        req =
          defaultRequest
            { url = endpointUrl
            , method = Left method
            , content = RequestBody.string <$> mBody
            , responseFormat = ResponseFormat.string
            , headers = [ RequestHeader "Authorization" ("Bearer " <> config_.apiKey) ]
            }
      resEither <- ʌ' $ request req
      case resEither of
        Left err -> ʌ' $ throwError $ error $ "Mailchimp (" <> endpointUrl <> "): " <> printError err
        Right res -> do
          let (StatusCode code) = res.status
          if code >= 200 && code < 300 then
            η res.body
          else ʌ' $ throwError $ error $ "Mailchimp Error (" <> endpointUrl <> ") " <> show code <> " - " <> res.body

prefillCampaign :: ∀ fx. NewsletterId -> String -> Array PrefillArticle -> Run (READER_MAILCHIMP_CONFIG + EFFECT + AFF + fx) Ɩ
prefillCampaign _newsletterId campaignName prefillArticles = do
  config <- askConfig
  case config of
    Nothing -> ηι
    Just config_ -> do
      -- 1. Duplication de la campagne brouillon maitre
      replicateResStr <- sendRequest POST ("campaigns/" <> config_.masterDraftId <> "/actions/replicate") Nothing
      
      -- 2. Parser le JSON de retour, extraire le nouvel ID
      json1 <- case (Yoga.JSON.readJSON_ replicateResStr) of
          Nothing -> ʌ' $ throwError $ error $ "Failed to parse replicate JSON"
          Just j -> η j
      (replicateRes :: { id :: String }) <- case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json1) of
          Left e -> ʌ' $ throwError $ error $ "Failed to decode replicate response: " <> show e
          Right json -> η json
      let newCampaignId = replicateRes.id
      
      -- 2.5 Rename the new campaign
      let patchBody = Yoga.JSON.writeJSON { settings: { title: campaignName } }
      _ <- sendRequest PATCH ("campaigns/" <> newCampaignId) (Just patchBody)
      
      -- 3. GET le contenu HTML du nouvel ID
      contentResStr <- sendRequest GET ("campaigns/" <> newCampaignId <> "/content") Nothing
      json2 <- case (Yoga.JSON.readJSON_ contentResStr) of
          Nothing -> ʌ' $ throwError $ error $ "Failed to parse content JSON"
          Just json -> η json
      (contentRes :: { html :: String }) <- case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json2) of
          Left e -> ʌ' $ throwError $ error $ "Failed to decode content response: " <> show e
          Right json -> η json
      
      -- 4. str_replace des variables
      let
        indices = [1, 2, 3, 4, 5, 6]
        
        getArticleData i = case Array.index prefillArticles (i - 1) of
          Just a -> a
          Nothing -> { title: "", lead: "", extract: "", authorName: "", bookNames: [], bookAuthors: [], bookEditors: [], bookYears: [], bookPrefix: "", link: "", keywords: [], illustrationUrl: "", bookCoverUrl: "" }

        allTagsToReplace = Array.filter (\(Tuple k _) -> k /= "") $ Array.concatMap (\i ->
          let a = getArticleData i
              si = show i
              fakeImgLandscape = "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/b76900a8-4e63-8c81-2bc4-cc15bd769d67.png"
              fakeImgCover = case i of
                1 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/19a1ca80-a52d-3d6c-88f8-380065dd6b14.png"
                2 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/ed9a7430-53e6-311d-0e17-c0547433c6d1.png"
                3 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/ab3ae2b5-ba00-b11f-7908-39f0ccc15338.png"
                4 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/94c32991-aaac-2711-d209-dab8818269d2.png"
                5 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/cf17c901-a316-3f7c-aec0-d135e4636874.png"
                _ -> ""
          in
          [ Tuple ("[Titre " <> si <> "]") a.title
          , Tuple ("[Chapô " <> si <> "]") a.lead
          , Tuple ("[Extrait " <> si <> "]") a.extract
          , Tuple ("[Auteur de l'article " <> si <> "]") a.authorName
          , Tuple ("[Nom du livre " <> si <> "]") (joinWith ", " a.bookNames)
          , Tuple ("[Auteur(s) du livre " <> si <> "]") (joinWith ", " a.bookAuthors)
          , Tuple ("[Nom de l'éditeur du livre " <> si <> "]") (joinWith ", " a.bookEditors)
          , Tuple ("[Année de parution du livre " <> si <> "]") (joinWith ", " a.bookYears)
          , Tuple ("[MOT-CLÉ " <> si <> "]") (joinWith ", " a.keywords)
          , Tuple ("[Préfixe pour auteur(s) du livre " <> si <> "]") a.bookPrefix
          , Tuple ("[Lien " <> si <> "]") a.link
          , Tuple ("https://lien" <> si) a.link
          ] <> (if i == 1 then [ Tuple fakeImgLandscape a.illustrationUrl, Tuple fakeImgCover a.bookCoverUrl ] else [ Tuple fakeImgCover a.bookCoverUrl ])
        ) indices
        
      let
        replaceRobust tag value htmlContent =
          let
            patternStr = toRobustHtmlRegexPattern tag
            regexOpt = Regex.regex patternStr (RegexFlags.global <> RegexFlags.ignoreCase)
          in
            case regexOpt of
              Right r -> Regex.replace r value htmlContent
              Left _ -> htmlContent
        
        modifiedHtml = foldl (\html (Tuple tag value) -> replaceRobust tag value html) contentRes.html allTagsToReplace

      -- 5. PUT le contenu HTML
      let putBody = Yoga.JSON.writeJSON { html: modifiedHtml }
      _ <- sendRequest PUT ("campaigns/" <> newCampaignId <> "/content") (Just putBody)
      
      ηι

getPrefilledMasterTemplateHtml :: ∀ fx. Array PrefillArticle -> Run (READER_MAILCHIMP_CONFIG + EFFECT + AFF + fx) String
getPrefilledMasterTemplateHtml prefillArticles = do
  config <- askConfig
  case config of
    Nothing -> η ""
    Just config_ -> do
      -- GET le contenu HTML de la campagne master directement
      contentResStr <- sendRequest GET ("campaigns/" <> config_.masterDraftId <> "/content") Nothing
      json2 <- case (Yoga.JSON.readJSON_ contentResStr) of
          Nothing -> ʌ' $ throwError $ error $ "Failed to parse content JSON"
          Just json -> η json
      (contentRes :: { html :: String }) <- case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json2) of
          Left e -> ʌ' $ throwError $ error $ "Failed to decode content response: " <> show e
          Right json -> η json
      
      -- str_replace des variables
      let
        indices = [1, 2, 3, 4, 5, 6]
        
        getArticleData i = case Array.index prefillArticles (i - 1) of
          Just a -> a
          Nothing -> { title: "", lead: "", extract: "", authorName: "", bookNames: [], bookAuthors: [], bookEditors: [], bookYears: [], bookPrefix: "", link: "", keywords: [], illustrationUrl: "", bookCoverUrl: "" }

        allTagsToReplace = Array.filter (\(Tuple k _) -> k /= "") $ Array.concatMap (\i ->
          let a = getArticleData i
              si = show i
              fakeImgLandscape = "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/b76900a8-4e63-8c81-2bc4-cc15bd769d67.png"
              fakeImgCover = case i of
                1 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/19a1ca80-a52d-3d6c-88f8-380065dd6b14.png"
                2 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/ed9a7430-53e6-311d-0e17-c0547433c6d1.png"
                3 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/ab3ae2b5-ba00-b11f-7908-39f0ccc15338.png"
                4 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/94c32991-aaac-2711-d209-dab8818269d2.png"
                5 -> "https://mcusercontent.com/154b79215adad7bb6fbdd9549/images/cf17c901-a316-3f7c-aec0-d135e4636874.png"
                _ -> ""
          in
          [ Tuple ("[Titre " <> si <> "]") a.title
          , Tuple ("[Chapô " <> si <> "]") a.lead
          , Tuple ("[Extrait " <> si <> "]") a.extract
          , Tuple ("[Auteur de l'article " <> si <> "]") a.authorName
          , Tuple ("[Nom du livre " <> si <> "]") (joinWith ", " a.bookNames)
          , Tuple ("[Auteur(s) du livre " <> si <> "]") (joinWith ", " a.bookAuthors)
          , Tuple ("[Nom de l'éditeur du livre " <> si <> "]") (joinWith ", " a.bookEditors)
          , Tuple ("[Année de parution du livre " <> si <> "]") (joinWith ", " a.bookYears)
          , Tuple ("[MOT-CLÉ " <> si <> "]") (joinWith ", " a.keywords)
          , Tuple ("[Préfixe pour auteur(s) du livre " <> si <> "]") a.bookPrefix
          , Tuple ("[Lien " <> si <> "]") a.link
          , Tuple ("https://lien" <> si) a.link
          ] <> (if i == 1 then [ Tuple fakeImgLandscape a.illustrationUrl, Tuple fakeImgCover a.bookCoverUrl ] else [ Tuple fakeImgCover a.bookCoverUrl ])
        ) indices
        
      let
        replaceRobust tag value htmlContent =
          let
            patternStr = toRobustHtmlRegexPattern tag
            regexOpt = Regex.regex patternStr (RegexFlags.global <> RegexFlags.ignoreCase)
          in
            case regexOpt of
              Right r -> Regex.replace r value htmlContent
              Left _ -> htmlContent
        
        modifiedHtml = foldl (\html (Tuple tag value) -> replaceRobust tag value html) contentRes.html allTagsToReplace

      η modifiedHtml

