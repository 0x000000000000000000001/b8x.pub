module Inter.Cli.Util.Aff
  (runCliAff
  ) where

import Proem

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, bracket, launchAff_, runAff_)
import Effect.Console as Console
import Effect.Exception (Error)
import Inter.Cli.Util.Exit (exitError, exitSuccess)
import Util.Timer (IntervalId, _clearInterval, _setInterval)

runCliAff :: Aff Ɩ -> Effect Ɩ
runCliAff aff = runAff_ handleResult (_protectAffFromNodeKillIfEverlasting aff)
  where
  handleResult :: Either Error Ɩ -> Effect Ɩ
  handleResult (Right _) = exitSuccess
  handleResult (Left e) = launchAff_ do
    ʌ $ Console.error $ "🧨 " <> show e

    -- sesClient <- Ses.createInnerClient internalConfig.mail

    -- Ses.sendBugMail_ sesClient internalConfig.mail
    --   { to: { name: "Kévin", email: "kevin.francart3@gmail.com" }
    --   , subject: "[" <> show config.env <> "] Error"
    --   , text: show e
    --   , html: "<pre>" <> show e <> "</pre>"
    --   }

    exitError

-- | Special function. 
-- | Wraps an Aff action, ensuring the Node's event loop does not consider it as abnormal 
-- | (and kill it), when it is everlasting. 
-- | Even if the action seems active to the PureScript dev, it might not hold any actual Node handle 
-- | (since PureScript's async runtime is opaque to Node).
-- | This function fixes that by keeping a timer active for the duration of the Aff.
-- | Guarantees cleanup (stopping the timer) via `bracket`.
_protectAffFromNodeKillIfEverlasting :: Aff ~> Aff
_protectAffFromNodeKillIfEverlasting action =
  bracket acquire release (const action)
  where
  -- Action to acquire the resource (start the timer)
  acquire :: Aff IntervalId
  acquire =
    ʌ $ _setInterval 10000 ηι -- A timer that does nothing every 10s

  -- Action to release the resource (clear the timer)
  release :: IntervalId -> Aff Ɩ
  release id =
    ʌ $ _clearInterval id

