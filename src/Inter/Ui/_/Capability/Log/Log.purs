module Inter.Ui.Capability.Log.Log where

import Proem

import Effect.Class.Console as Console
import Run (EFFECT, Run)
import Run as Run
import Type.Row (type (+))
import Util.Log (Level(..))

data Log a = Log Level String a

derive instance Functor Log

type LOG fx = (log :: Log | fx)

log' = π :: Π "log"

log_ :: ∀ fx. Level -> String -> Run (LOG + fx) Ɩ
log_ level msg = Run.lift log' (Log level msg unit)

logShow_ :: ∀ a fx. Show a => Level -> a -> Run (LOG + fx) Ɩ
logShow_ level a = log_ level (show a)

info_ :: ∀ fx. String -> Run (LOG + fx) Ɩ
info_ msg = log_ Info msg

infoShow_ :: ∀ a fx. Show a => a -> Run (LOG + fx) Ɩ
infoShow_ a = logShow_ Info a

debug_ :: ∀ fx. String -> Run (LOG + fx) Ɩ
debug_ msg = log_ Debug msg

debugShow_ :: ∀ a fx. Show a => a -> Run (LOG + fx) Ɩ
debugShow_ a = logShow_ Debug a

warn_ :: ∀ fx. String -> Run (LOG + fx) Ɩ
warn_ msg = log_ Warn msg

warnShow_ :: ∀ a fx. Show a => a -> Run (LOG + fx) Ɩ
warnShow_ a = logShow_ Warn a

error_ :: ∀ fx. String -> Run (LOG + fx) Ɩ
error_ msg = log_ Error msg

errorShow_ :: ∀ a fx. Show a => a -> Run (LOG + fx) Ɩ
errorShow_ a = logShow_ Error a

interpretLog :: ∀ fx. Run (LOG + EFFECT + fx) ~> Run (EFFECT + fx)
interpretLog = Run.interpret (Run.on log' handle Run.send)
  where
  handle :: ∀ a fx'. Log a -> Run (EFFECT + fx') a
  handle (Log level message next) = do
    let msg = show level <> ": " <> message

    case level of
      Debug -> Console.debug msg
      Info -> Console.info msg
      Warn -> Console.warn msg
      Error -> Console.error msg

    η next
