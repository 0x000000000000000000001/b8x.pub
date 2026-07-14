module Infra.Client.Aws.S3.S3 where

import Proem

import Config.InternalConfig (S3Config)
import Config.PublicConfig (publicConfig)
import Promise.Aff (Promise, toAffE)
import Promise.Internal as PromiseInternal
import Core.Exception.Exception (throw)
import Core.Exception.Index (EXCEPT_LOGIC)
import Core.Message.Command.Handle.Upload (UPLOAD, Upload(..), upload')
import Core.Mod.Image.Exception.ImageCannotBeUploaded (ImageCannotBeUploaded(..))
import Core.Mod.Image.Image (Image(..))
import Core.Mod.MimeType (mimeTypeToExtension)
import Data.Array (head)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff (try)
import Effect.Aff.Class (class MonadAff)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Util.Log.Error (error)
import Partial.Unsafe (unsafeCrashWith)
import Run (AFF, EFFECT, Run, interpret, on, send)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))
import Util.Type.String.ToString (fromString, toString)

foreign import data InnerClient :: Type

type Client =
  { clientRef :: Ref (Maybe InnerClient)
  , config :: S3Config
  }

type READER_S3_CLIENT fx = (readerS3Client :: Reader Client | fx)

readerS3Client' = π :: Π "readerS3Client"

runS3ClientReader :: ∀ fx a. Client -> Run (READER_S3_CLIENT + fx) a -> Run fx a
runS3ClientReader = runReaderAt readerS3Client'

createLazyClient :: ∀ m. MonadAff m => S3Config -> m Client
createLazyClient config = do
  clientRef <- ʌ $ Ref.new Nothing
  η $ { clientRef, config }

createClient :: ∀ m. MonadAff m => S3Config -> m Client
createClient config = do
  client <- createInnerClient config
  clientRef <- ʌ $ Ref.new (Just client)
  η $ { clientRef, config }

createInnerClient :: ∀ m. MonadAff m => S3Config -> m InnerClient
createInnerClient { region, accessKeyId, secretAccessKey } = ʌ $ _createInnerClient region accessKeyId secretAccessKey

foreign import _createInnerClient :: String -> String -> String -> Effect InnerClient

type UploadResult =
  { src :: String
  , hash :: String
  , mimeType :: String
  , size :: Int
  , dimensions ::
      { width :: Int
      , height :: Int
      }
  }

type Bucket = String
type IsPublic = Boolean
type BucketDirectory = String
type Url = String
type MimeTypeToExtension = String -> String

foreign import _uploadUrlContentImpl :: ∀ newFn. newFn -> InnerClient -> Bucket -> IsPublic -> BucketDirectory -> Boolean -> Boolean -> Url -> MimeTypeToExtension -> Effect (Promise UploadResult)

_uploadUrlContent :: InnerClient -> Bucket -> IsPublic -> BucketDirectory -> Boolean -> Boolean -> Url -> MimeTypeToExtension -> Effect (Promise UploadResult)
_uploadUrlContent = _uploadUrlContentImpl PromiseInternal.new

foreign import _uploadHtmlUrlContentsImpl :: ∀ newFn. newFn -> InnerClient -> Bucket -> IsPublic -> BucketDirectory -> MimeTypeToExtension -> Boolean -> String -> String -> String -> Effect (Promise String)

_uploadHtmlUrlContents :: InnerClient -> Bucket -> IsPublic -> BucketDirectory -> MimeTypeToExtension -> Boolean -> String -> String -> String -> Effect (Promise String)
_uploadHtmlUrlContents = _uploadHtmlUrlContentsImpl PromiseInternal.new

uploadUrlContent_ :: ∀ fx. InnerClient -> Bucket -> BucketDirectory -> Boolean -> Boolean -> Url -> Run (EXCEPT_LOGIC + EFFECT + AFF + fx) (Maybe Image)
uploadUrlContent_ client bucket bucketDirectory autocropBlackWhite autocropTransparent url = do
  result <- ʌ' $ try $ toAffE $
    _uploadUrlContent
      client
      bucket
      true
      bucketDirectory
      autocropBlackWhite
      autocropTransparent
      (toString url)
      ( \m -> case fromString m >>= mimeTypeToExtension >>= head of
          Just ext -> toString ext
          Nothing -> unsafeCrashWith ("Mime type not supported: " <> m)
      )

  case result of
    Left err -> do
      error $ "Upload exception: " <> show err
      η Nothing
    Right { src, hash, mimeType: mimeType_, size, dimensions: { width, height } } -> do
      let
        mimeType = case fromString mimeType_ of
          Just m -> m
          Nothing -> unsafeCrashWith ("Invalid mime type: " <> mimeType_)

      η $ Just $ Image { src, hash, mimeType, size, dimensions: { width, height } }

uploadUrlContent :: ∀ fx. BucketDirectory -> Boolean -> Boolean -> Url -> Run (EXCEPT_LOGIC + READER_S3_CLIENT + EFFECT + AFF + fx) (Maybe Image)
uploadUrlContent bucketDirectory autocropBlackWhite autocropTransparent url = do
  client <- askInnerClient
  config <- askConfig

  uploadUrlContent_ client config.bucket bucketDirectory autocropBlackWhite autocropTransparent url

uploadHtmlUrlContents_ :: ∀ fx. InnerClient -> Bucket -> BucketDirectory -> Boolean -> String -> Run (EXCEPT_LOGIC + EFFECT + AFF + fx) String
uploadHtmlUrlContents_ client bucket bucketDirectory shouldRelativize content = do
  result <- ʌ' $ try $ toAffE $
    _uploadHtmlUrlContents
      client
      bucket
      true
      bucketDirectory
      ( \m -> case fromString m >>= mimeTypeToExtension >>= head of
          Just ext -> toString ext
          Nothing -> unsafeCrashWith ("Mime type not supported: " <> m)
      )
      shouldRelativize
      ("https://" <> publicConfig.ui.host)
      ("https://" <> publicConfig.ui.legacyHost)
      content

  case result of
    Left err -> do
      error $ "Upload html images exception: " <> show err
      η content
    Right updatedContent -> η updatedContent

uploadHtmlUrlContents :: ∀ fx. BucketDirectory -> Boolean -> String -> Run (EXCEPT_LOGIC + READER_S3_CLIENT + EFFECT + AFF + fx) String
uploadHtmlUrlContents bucketDirectory shouldRelativize content = do
  client <- askInnerClient
  config <- askConfig
  uploadHtmlUrlContents_ client config.bucket bucketDirectory shouldRelativize content

ensureInnerClient :: ∀ fx. Client -> Run (READER_S3_CLIENT + EFFECT + AFF + fx) InnerClient
ensureInnerClient { clientRef, config } = do
  maybeClient <- ʌ $ Ref.read clientRef
  case maybeClient of
    Just client -> η client
    Nothing -> do
      client <- createInnerClient config
      ʌ $ Ref.write (Just client) clientRef
      η client

askClient :: ∀ fx. Run (READER_S3_CLIENT + EFFECT + AFF + fx) Client
askClient = askAt readerS3Client'

askInnerClient :: ∀ fx. Run (READER_S3_CLIENT + EFFECT + AFF + fx) InnerClient
askInnerClient = ensureInnerClient =<< askClient

askConfig :: ∀ fx. Run (READER_S3_CLIENT + EFFECT + AFF + fx) S3Config
askConfig = askClient >>= (_.config ▷ η)

interpretUpload
  :: ∀ fx a
   . Run (UPLOAD + READER_S3_CLIENT + EXCEPT_LOGIC + EFFECT + AFF + fx) a
  -> Run (READER_S3_CLIENT + EXCEPT_LOGIC + EFFECT + AFF + fx) a
interpretUpload = interpret (on upload' handle send)
  where
  handle :: ∀ fx' a'. Upload a' -> Run (READER_S3_CLIENT + EXCEPT_LOGIC + EFFECT + AFF + fx') a'
  handle (UploadImage autocropBlackWhite autocropTransparent url next) = do
    img <- uploadUrlContent "image" autocropBlackWhite autocropTransparent (toString url)
    case img of
      Nothing -> throw $ ImageCannotBeUploaded $ toString url
      Just i -> η $ next i
  handle (UploadHtmlImages shouldRelativize content next) = do
    updatedContent <- uploadHtmlUrlContents "image" shouldRelativize content
    η $ next updatedContent
