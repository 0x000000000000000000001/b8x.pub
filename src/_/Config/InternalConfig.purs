module Config.InternalConfig
  ( AuthConfig
  , AwsConfig
  , DbConfig
  , DbSubConfig
  , HelloAssoConfig
  , InternalConfig
  , InternalConfigRow
  , MailConfig
  , MailchimpConfig
  , MqConfig
  , OrchConfig
  , READER_INTERNAL_CONFIG
  , S3Config
  , SendyConfig
  , SesConfig
  , askInternalConfig
  , fullModuleName
  , internalConfig
  , readerInternalConfig'
  , runInternalConfigReader
  , s3ImageUrl
  ) where

import Proem

import Run (Run)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))

type AuthConfig =
  { pasetoLocalKey :: String
  }

fullModuleName :: String
fullModuleName = "Config.InternalConfig"

foreign import _config :: InternalConfig

type DbConfig =
  { store :: DbSubConfig
  , storeLock :: DbSubConfig
  , edge :: DbSubConfig
  }

type DbSubConfig =
  { host :: String
  , directHost :: String
  , port :: Int
  , database :: String
  , user :: String
  , password :: String
  , idleTimeoutMs :: Int
  }

type MqConfig =
  { host :: String
  , port :: Int
  , user :: String
  , password :: String
  , queue ::
      { command ::
          { logic :: String
          }
      , event ::
          { logic :: String
          }
      }
  }

type MailConfig =
  { from ::
      { name :: String
      , email ::
          { transaction :: String
          , bug :: String
          , newsletter :: String
          }
      }
  , ses :: SesConfig
  , sendy :: SendyConfig
  }

type MailchimpConfig =
  { apiKey :: String
  , masterDraftId :: String
  , serverPrefix :: String
  }

type AwsConfig =
  { ses :: SesConfig
  , s3 :: S3Config
  }

type SesConfig =
  { region :: String
  , accessKeyId :: String
  , secretAccessKey :: String
  }

type S3Config =
  { region :: String
  , bucket :: String
  , accessKeyId :: String
  , secretAccessKey :: String
  , urlBase :: String
  }

type SendyConfig =
  { licenseKey :: String
  , awsIam ::
      { accessKeyId :: String
      , secretAccessKey :: String
      }
  , user :: String
  , password :: String
  , apiKey :: String
  , brandId :: String
  , listId :: String
  , host :: String
  }

type OrchConfig =
  { services ::
      { api ::
          { name :: String
          , worker ::
              { name :: String
              }
          }
      , proj ::
          { namePrefix :: String
          }
      }
  }

type HelloAssoConfig =
  { clientId :: String
  , clientSecret :: String
  , webhookSecret :: String
  }

s3ImageUrl :: String -> String
s3ImageUrl bucketPath = _config.aws.s3.urlBase <> bucketPath

type InternalConfigRow r =
  ( name :: String
  , db :: { store :: DbSubConfig, storeLock :: DbSubConfig, edge :: DbSubConfig }
  , mq :: MqConfig
  , mail :: MailConfig
  , aws :: AwsConfig
  , sendy :: SendyConfig
  , orch :: OrchConfig
  , auth :: AuthConfig
  , helloAsso :: HelloAssoConfig
  , mailchimp :: MailchimpConfig
  | r
  )

type InternalConfig = { | InternalConfigRow () }

internalConfig :: InternalConfig
internalConfig =
  { name: _config.name
  , db: _config.db
  , mq:
      { host: _config.mq.host
      , port: _config.mq.port
      , user: _config.mq.user
      , password: _config.mq.password
      , queue:
          { command:
              { logic: "command.logic"
              }
          , event:
              { logic: "event.logic"
              }
          }
      }
  , mail:
      { from:
          { name: _config.mail.from.name
          , email:
              { transaction: _config.mail.from.email.transaction
              , bug: _config.mail.from.email.bug
              , newsletter: _config.mail.from.email.newsletter
              }
          }
      , ses: _config.aws.ses
      , sendy: _config.sendy
      }
  , aws:
      { s3: _config.aws.s3
      , ses: _config.aws.ses
      }
  , sendy: _config.sendy
  , orch:
      { services:
          { api:
              { name: "api"
              , worker:
                  { name: "api-worker"
                  }
              }
          , proj:
              { namePrefix: "proj-"
              }
          }
      }
  , auth: _config.auth
  , helloAsso: _config.helloAsso
  , mailchimp: _config.mailchimp
  }

type READER_INTERNAL_CONFIG fx = (readerInternalConfig :: Reader InternalConfig | fx)

readerInternalConfig' = π :: Π "readerInternalConfig"

runInternalConfigReader :: ∀ fx a. InternalConfig -> Run (READER_INTERNAL_CONFIG + fx) a -> Run fx a
runInternalConfigReader = runReaderAt readerInternalConfig'

askInternalConfig :: ∀ fx. Run (READER_INTERNAL_CONFIG + fx) InternalConfig
askInternalConfig = askAt readerInternalConfig'
