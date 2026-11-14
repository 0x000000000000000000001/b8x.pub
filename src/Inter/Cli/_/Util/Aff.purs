module Inter.Cli.Util.Aff
  ( runCliAff
  ) where

import Proem

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, launchAff_, runAff_)
import Effect.Console as Console
import Effect.Exception (Error)
import Inter.Cli.Util.Exit (exitError, exitSuccess)
import Inter.Cli.Util.KeepAlive (keepMainAlive)

runCliAff :: Aff Ɩ -> Effect Ɩ
runCliAff aff = do
  runAff_ handleResult aff
  keepMainAlive
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
