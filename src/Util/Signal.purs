module Util.Signal where

import Proem

import Control.Monad.Reader (class MonadReader, ask)
import Data.Maybe (Maybe(..), isJust)
import Effect (Effect)
import Effect.Class (class MonadEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Run (Run, EFFECT)
import Run.Reader (Reader, askAt, runReaderAt)
import Inter.Cli.Util.Exit (exitSuccess)
import Util.Log.Log (log)
import Type.Row (type (+))

foreign import _onSignal :: String -> Effect Ɩ -> Effect Ɩ

data Signal = INT | TERM | QUIT

type SignalRef = Ref (Maybe Signal)

type READER_SIGNAL_REF fx = (readerSignalRef :: Reader SignalRef | fx)

readerSignalRef' = π :: Π "readerSignalRef"

runSignalRefReader :: ∀ fx a. SignalRef -> Run (READER_SIGNAL_REF + fx) a -> Run fx a
runSignalRefReader = runReaderAt readerSignalRef'

derive instance Eq Signal

instance Show Signal where
  show INT = "SIGINT"
  show TERM = "SIGTERM"
  show QUIT = "SIGQUIT"

initSignal :: ∀ m. MonadEffect m => m SignalRef
initSignal = do
  ref <- ʌ $ Ref.new Nothing

  let
    handler sig = Ref.write (Just sig) ref

  ʌ $ _onSignal (show INT) (handler INT)
  ʌ $ _onSignal (show TERM) (handler TERM)
  ʌ $ _onSignal (show QUIT) (handler QUIT)

  η ref

considerSignal__ :: ∀ m. MonadEffect m => Maybe String -> SignalRef -> m Ɩ -> m Ɩ
considerSignal__ prefix ref cb = do
  sig <- ʌ $ Ref.read ref

  when
    (isJust sig)
    (do
        let p = case prefix of
              Just s -> s
              Nothing -> ""
        ʌ $ log $ p <> "Received " <> (sig ?? show ⇔ "?") <> ". Stopped."
        cb
        exitSuccess
    )

considerSignal_ :: ∀ m. MonadEffect m => MonadReader SignalRef m => Maybe String -> m Ɩ -> m Ɩ
considerSignal_ prefix cb = do
  signalRef <- ask

  considerSignal__ prefix signalRef cb

considerSignal :: ∀ fx. Maybe String -> Run (READER_SIGNAL_REF + EFFECT + fx) Ɩ -> Run (READER_SIGNAL_REF + EFFECT + fx) Ɩ
considerSignal prefix cb = do
  signalRef <- askAt readerSignalRef'

  considerSignal__ prefix signalRef cb

triggerSignal :: ∀ m. MonadEffect m => SignalRef -> m Ɩ
triggerSignal ref = ʌ $ Ref.write (Just INT) ref

