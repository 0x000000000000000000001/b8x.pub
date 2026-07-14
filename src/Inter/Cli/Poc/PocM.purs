module Inter.Cli.Poc.PocM where

import Proem

import Config.InternalConfig (internalConfig)
import Effect.Aff (Aff)
import Infra.Client.Sendy (READER_SENDY_CONFIG, runSendyConfigReader)
import Infra.Client.Mailchimp.Mailchimp (READER_MAILCHIMP_CONFIG, runMailchimpConfigReader)
import Infra.Client.Mailchimp.Mailchimp as Mailchimp
import Infra.Client.Sendy as Sendy
import Run (Run, AFF, EFFECT, runBaseAff')
import Type.Row (type (+))

type POC =
  READER_SENDY_CONFIG
    + READER_MAILCHIMP_CONFIG
    + AFF
    + EFFECT
    + ()

type PocM = Run POC

type Context =
  { sendyConfig :: Sendy.Config
  , mailchimpConfig :: Mailchimp.Config
  }

runPocM :: ∀ a. Context -> PocM a -> Aff a
runPocM { sendyConfig, mailchimpConfig } = do
  runMailchimpConfigReader mailchimpConfig
    ▷ runSendyConfigReader sendyConfig
    ▷ runBaseAff'

acquire :: Aff Context
acquire = do
  sendyConfig <- Sendy.createConfig internalConfig.sendy
  mailchimpConfig <- Mailchimp.createConfig internalConfig.mailchimp

  η { sendyConfig, mailchimpConfig }

complete :: Context -> Aff Ɩ
complete _ = ηι
