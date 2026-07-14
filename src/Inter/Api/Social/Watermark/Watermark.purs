module Inter.Api.Social.Watermark.Watermark where

import Proem

import Affjax.ResponseFormat (arrayBuffer)
import Promise.Aff (Promise, toAffE)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.String (toLower)
import Data.String as String
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Aff as Aff
import Foreign.Object as Object
import Inter.Api.ApiM (Context)
import Inter.Api.Social.Meta.Meta (sendHtml)
import JSURI (decodeURIComponent)
import Node.Buffer (Buffer, fromArrayBuffer)
import Node.HTTP.IncomingMessage (headers)
import Node.HTTP.Types (IMServer, IncomingMessage, ServerResponse)
import Util.File.Path (assetDirAbsolutePath)
import Util.Http.Http (getCheckStatus)
import Util.Type.String.ToString (class ToString, toString)

data WatermarkPosition = TopLeft | BottomLeft | BottomCenter | BottomRight

derive instance Eq WatermarkPosition

instance ToString WatermarkPosition where
  toString TopLeft = "TopLeft"
  toString BottomLeft = "BottomLeft"
  toString BottomCenter = "BottomCenter"
  toString BottomRight = "BottomRight"

foreign import _watermarkImage :: String -> Int -> Boolean -> Buffer -> String -> Effect (Promise Buffer)

foreign import _defaultImage :: String -> Effect (Promise Buffer)

foreign import _sendImage :: ServerResponse -> Buffer -> Effect Ɩ

handleSocialWatermark :: Maybe String -> Maybe String -> Context -> IncomingMessage IMServer -> ServerResponse -> Aff Ɩ
handleSocialWatermark mEncodedUrl mAgent _ctx req res = do
  let
    serveDefaultImage = do
      let logoPath = assetDirAbsolutePath <> "/image/social.logo.jpg"
      resEither <- Aff.try $ toAffE (_defaultImage logoPath)
      case resEither of
        Right buf -> ʌ $ _sendImage res buf
        Left _ -> sendHtml res 500 "Internal Server Error"

  case mEncodedUrl of
    Nothing -> serveDefaultImage
    Just encodedUrl -> case decodeURIComponent encodedUrl of
      Just url -> do
        let
          headersObj = headers req
          userAgent = String.toLower (Object.lookup "user-agent" headersObj ??⇒ "")
          mAgent' = mAgent <#> toLower
          isLinkedin = mAgent' == Just "linkedin" || String.contains (String.Pattern "linkedinbot") userAgent
          position = case mAgent' of
            Just "linkedin" -> BottomRight
            Just "x" -> TopLeft
            Just "twitter" -> TopLeft
            Just "facebook" -> BottomLeft
            _
              | isLinkedin -> BottomRight
              | String.contains (String.Pattern "twitterbot") userAgent -> TopLeft
              | otherwise -> BottomLeft

          scalePct = 100
          showLogo = not isLinkedin

        resEither <- watermarkImage position scalePct showLogo url
        case resEither of
          Right buf -> ʌ $ _sendImage res buf
          Left _ -> serveDefaultImage
      Nothing -> serveDefaultImage

watermarkImage :: WatermarkPosition -> Int -> Boolean -> String -> Aff (Either String Buffer)
watermarkImage position scalePct showLogo url = do
  response <- getCheckStatus arrayBuffer url
  response
    ?!
      ( \res -> do
          buf <- ʌ $ fromArrayBuffer res.body
          let logoPath = assetDirAbsolutePath <> "/image/logo.svg"
          finalBuf <- toAffE (_watermarkImage (toString position) scalePct showLogo buf logoPath)
          η (Right finalBuf)
      )
    ⇿ (η ◁ Left)
