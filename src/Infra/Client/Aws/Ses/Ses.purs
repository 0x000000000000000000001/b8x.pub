module Infra.Client.Aws.Ses.Ses where

import Proem

import Config.InternalConfig (MailConfig)
import Promise.Aff (Promise, toAffE)
import Promise.Internal as PromiseInternal
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Run (AFF, EFFECT, Run)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))

foreign import data InnerClient :: Type

type Client =
  { clientRef :: Ref (Maybe InnerClient)
  , config :: MailConfig
  }

type READER_SES_CLIENT fx = (readerSesClient :: Reader Client | fx)

readerSesClient' = π :: Π "readerSesClient"

runSesClientReader :: ∀ fx a. Client -> Run (READER_SES_CLIENT + fx) a -> Run fx a
runSesClientReader = runReaderAt readerSesClient'

createLazyClient :: ∀ m. MonadAff m => MailConfig -> m Client
createLazyClient config = do
  clientRef <- ʌ $ Ref.new Nothing
  η $ { clientRef, config }

createClient :: ∀ m. MonadAff m => MailConfig -> m Client
createClient config = do
  client <- createInnerClient config
  clientRef <- ʌ $ Ref.new (Just client)
  η $ { clientRef, config }

createInnerClient :: ∀ m. MonadAff m => MailConfig -> m InnerClient
createInnerClient { ses: { region, accessKeyId, secretAccessKey } } = ʌ $ _createInnerClient region accessKeyId secretAccessKey

foreign import _createInnerClient :: String -> String -> String -> Effect InnerClient

type Contact =
  { email :: String
  , name :: String
  }

type MinMailOptionsRow =
  (to :: Contact
  , subject :: String
  , text :: String
  , html :: String
  )

type MinMailOptions = { | MinMailOptionsRow }

type MailOptions =
  { from :: Contact
  | MinMailOptionsRow
  }

foreign import _sendMailImpl :: forall newFn. newFn -> InnerClient -> MailOptions -> Effect (Promise Unit)

_sendMail :: InnerClient -> MailOptions -> Effect (Promise Unit)
_sendMail = _sendMailImpl PromiseInternal.new

sendMail_ :: ∀ m. MonadAff m => InnerClient -> MailOptions -> m Ɩ
sendMail_ client opt = ʌ' $ toAffE $ _sendMail client opt

sendTransactionalMail_ :: ∀ m. MonadAff m => InnerClient -> MailConfig -> MinMailOptions -> m Ɩ
sendTransactionalMail_ client config { to, subject, text, html } = do
  let { from: { name, email: { transaction } } } = config
  sendMail_ client { from: { name, email: transaction }, to, subject, text, html }

sendBugMail_ :: ∀ m. MonadAff m => InnerClient -> MailConfig -> MinMailOptions -> m Ɩ
sendBugMail_ client config { to, subject, text, html } = do
  let { from: { name, email: { bug } } } = config
  sendMail_ client { from: { name, email: bug }, to, subject, text, html }

sendNewsletterMail_ :: ∀ m. MonadAff m => InnerClient -> MailConfig -> MinMailOptions -> m Ɩ
sendNewsletterMail_ client config { to, subject, text, html } = do
  let { from: { name, email: { newsletter } } } = config
  sendMail_ client { from: { name, email: newsletter }, to, subject, text, html }

sendMail :: ∀ fx. MailOptions -> Run (READER_SES_CLIENT + EFFECT + AFF + fx) Ɩ
sendMail opt = do
  client <- askInnerClient
  sendMail_ client opt

sendTransactionalMail :: ∀ fx. MinMailOptions -> Run (READER_SES_CLIENT + EFFECT + AFF + fx) Ɩ
sendTransactionalMail { to, subject, text, html } = do
  client <- askInnerClient
  config <- askConfig
  sendTransactionalMail_ client config { to, subject, text, html }

sendBugMail :: ∀ fx. MinMailOptions -> Run (READER_SES_CLIENT + EFFECT + AFF + fx) Ɩ
sendBugMail { to, subject, text, html } = do
  client <- askInnerClient
  config <- askConfig
  sendBugMail_ client config { to, subject, text, html }

sendNewsletterMail :: ∀ fx. MinMailOptions -> Run (READER_SES_CLIENT + EFFECT + AFF + fx) Ɩ
sendNewsletterMail { to, subject, text, html } = do
  client <- askInnerClient
  config <- askConfig
  sendNewsletterMail_ client config { to, subject, text, html }

ensureInnerClient :: ∀ fx. Client -> Run (READER_SES_CLIENT + EFFECT + AFF + fx) InnerClient
ensureInnerClient { clientRef, config } = do
  maybeClient <- ʌ $ Ref.read clientRef
  case maybeClient of
    Just client -> η client
    Nothing -> do
      client <- createInnerClient config
      ʌ $ Ref.write (Just client) clientRef
      η client

askClient :: ∀ fx. Run (READER_SES_CLIENT + EFFECT + AFF + fx) Client
askClient = askAt readerSesClient'

askInnerClient :: ∀ fx. Run (READER_SES_CLIENT + EFFECT + AFF + fx) InnerClient
askInnerClient = ensureInnerClient =<< askClient

askConfig :: ∀ fx. Run (READER_SES_CLIENT + EFFECT + AFF + fx) MailConfig
askConfig = askClient >>= (_.config ▷ η)
