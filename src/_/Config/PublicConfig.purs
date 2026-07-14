module Config.PublicConfig
  ( ApiConfig
  , HttpConfig
  , PublicConfig
  , PublicConfigRow
  , UiConfig
  , UiDns
  , UiDnsLevel2
  , ObjectStorageConfig
  , fullModuleName
  , publicConfig
  , READER_PUBLIC_CONFIG
  , readerPublicConfig'
  , runPublicConfigReader
  , askPublicConfig
  , toAbsolute_
  , toAbsolute
  , toApiAbsolute
  , toUiAbsolute
  ) where

import Proem
import Control.Monad.Except as Control.Monad.Except
import Foreign as Foreign
import Yoga.JSON (readImpl)
import Util.Env (Env(..))
import Run (Run)
import Run.Reader (Reader, askAt, runReaderAt)
import Type.Row (type (+))
import Data.String as String

fullModuleName :: String
fullModuleName = "Config.PublicConfig"

foreign import _publicConfig :: RawPublicConfig

type HttpConfig =
  { host :: String
  , port :: String
  , scheme :: String
  }

type UiDnsLevel2 = { a :: String, b :: String }
type UiDns = { level1 :: String, level2 :: UiDnsLevel2 }

type UiConfig =
  { host :: String
  , dns :: UiDns
  , legacyHost :: String
  , appId :: String
  }

type ApiConfig = HttpConfig

type ObjectStorageConfig =
  { urlBase :: String
  , publicPathBase :: String
  }

type RawPublicConfigRow r =
  ( env :: String
  , version :: String
  , api :: ApiConfig
  , ui :: UiConfig
  , objectStorage :: ObjectStorageConfig
  | r
  )

type PublicConfigRow r =
  ( env :: Env
  , version :: String
  , api :: ApiConfig
  , ui :: UiConfig
  , objectStorage :: ObjectStorageConfig
  | r
  )

type RawPublicConfig = { | RawPublicConfigRow () }

type PublicConfig = { | PublicConfigRow () }

publicConfig :: PublicConfig
publicConfig =
  { env: (Control.Monad.Except.runExcept (readImpl (Foreign.unsafeToForeign _publicConfig.env))) ?!⇽ κ Dev
  , version: _publicConfig.version
  , api: _publicConfig.api
  , ui:
      { host: _publicConfig.ui.host
      , dns: _publicConfig.ui.dns
      , legacyHost: _publicConfig.ui.legacyHost
      , appId: _publicConfig.ui.appId
      }
  , objectStorage:
      { urlBase: _publicConfig.objectStorage.urlBase
      , publicPathBase: "/public"
      }
  }

type READER_PUBLIC_CONFIG fx = (readerPublicConfig :: Reader PublicConfig | fx)

readerPublicConfig' = π :: Π "readerPublicConfig"

runPublicConfigReader :: ∀ fx a. PublicConfig -> Run (READER_PUBLIC_CONFIG + fx) a -> Run fx a
runPublicConfigReader = runReaderAt readerPublicConfig'

askPublicConfig :: ∀ fx. Run (READER_PUBLIC_CONFIG + fx) PublicConfig
askPublicConfig = askAt readerPublicConfig'

toAbsolute_ :: String -> String -> String
toAbsolute_ host path = "https://" <> host <> (String.take 1 path == "/" ? "" ↔ "/") <> path

toAbsolute :: ∀ fx. Boolean -> String -> Run (READER_PUBLIC_CONFIG + fx) String
toAbsolute isApi path = do
  config <- askPublicConfig
  η $ toAbsolute_ (isApi ? config.api.host ↔ config.ui.host) path

toApiAbsolute :: ∀ fx. String -> Run (READER_PUBLIC_CONFIG + fx) String
toApiAbsolute = toAbsolute true

toUiAbsolute :: ∀ fx. String -> Run (READER_PUBLIC_CONFIG + fx) String
toUiAbsolute = toAbsolute false
