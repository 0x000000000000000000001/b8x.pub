module Infra.Client.Nodemailer.Nodemailer where

import Proem

import Promise.Aff (Promise, toAffE)
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Run (AFF, EFFECT, Run)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))

foreign import data Transport :: Type

type Handles =
  { transport :: Transport
  }

data Client = Test
  { handlesRef :: Ref (Maybe Handles)
  }

-- Real
--     { handlesRef :: Ref (Maybe Handles)
--     , config :: MailConfig
--     }

type READER_NODEMAILER_CLIENT fx = (readerNodemailerClient :: Reader Client | fx)

readerNodemailerClient' = π :: Π "readerNodemailerClient"

runNodemailerClientReader :: ∀ fx a. Client -> Run (READER_NODEMAILER_CLIENT + fx) a -> Run fx a
runNodemailerClientReader = runReaderAt readerNodemailerClient'

-- createLazyClient :: ∀ m. MonadAff m => MailConfig -> m Client
-- createLazyClient config = do
--   handlesRef <- ʌ $ Ref.new Nothing
--   η $ Real { handlesRef, config }

createLazyTestClient :: ∀ m. MonadAff m => m Client
createLazyTestClient = do
  handlesRef <- ʌ $ Ref.new Nothing
  η $ Test { handlesRef }

-- createClient :: ∀ m. MonadAff m => MailConfig -> m Client
-- createClient config = do
--   handles <- createSharedNoTxHandles config
--   handlesRef <- ʌ $ Ref.new (Just handles)
--   η $ Real { handlesRef, config }

createTestClient :: ∀ m. MonadAff m => m Client
createTestClient = do
  handles <- createTestHandles
  handlesRef <- ʌ $ Ref.new (Just handles)
  η $ Test { handlesRef }

-- createSharedNoTxHandles :: ∀ m. MonadAff m => MailConfig -> m Handles
-- createSharedNoTxHandles { host, port, user, pass } = do
--   transport <- createTransport { host, port, auth: { user, pass } }
--   η { transport }

createTestHandles :: ∀ m. MonadAff m => m Handles
createTestHandles = do
  transport <- createTestTransport
  η { transport }

type TransportOptions =
  { host :: String
  , port :: Int
  , auth ::
      { user :: String
      , pass :: String
      }
  }

foreign import _createTransport :: TransportOptions -> Effect Transport
foreign import _createTestTransport :: Effect (Promise Transport)

createTransport :: ∀ m. MonadAff m => TransportOptions -> m Transport
createTransport opt = ʌ $ _createTransport opt

createTestTransport :: ∀ m. MonadAff m => m Transport
createTestTransport = ʌ' $ toAffE _createTestTransport

type MailOptions =
  { from :: String
  , to :: String
  , subject :: String
  , text :: String
  , html :: String
  , replyTo :: String
  }

foreign import _sendMail :: Transport -> MailOptions -> Effect (Promise Ɩ)

sendMail_ :: ∀ m. MonadAff m => Transport -> MailOptions -> m Ɩ
sendMail_ transport opt = ʌ' $ toAffE $ _sendMail transport opt

sendMail :: ∀ fx. MailOptions -> Run (READER_NODEMAILER_CLIENT + EFFECT + AFF + fx) Ɩ
sendMail opt = do
  transport <- askTransport
  sendMail_ transport opt

ensureHandles :: ∀ fx. Client -> Run (READER_NODEMAILER_CLIENT + EFFECT + AFF + fx) Handles
ensureHandles = case _ of
  -- Real { handlesRef, config } -> go handlesRef (createSharedNoTxHandles config)
  Test { handlesRef } -> go handlesRef createTestHandles
  where
  go handlesRef action = do
    maybeClient <- ʌ $ Ref.read handlesRef
    case maybeClient of
      Just handles -> η handles
      Nothing -> do
        handles <- action
        ʌ $ Ref.write (Just handles) handlesRef
        η handles

askClient :: ∀ fx. Run (READER_NODEMAILER_CLIENT + EFFECT + AFF + fx) Client
askClient = askAt readerNodemailerClient'

askHandles :: ∀ fx. Run (READER_NODEMAILER_CLIENT + EFFECT + AFF + fx) Handles
askHandles = ensureHandles =<< askClient

askTransport :: ∀ fx. Run (READER_NODEMAILER_CLIENT + EFFECT + AFF + fx) Transport
askTransport = askHandles >>= (_.transport ▷ η)
