module Config.Config
  (Config(..)
  , config
  ) where

import Config.InternalConfig (InternalConfigRow, internalConfig)
import Config.PublicConfig (PublicConfigRow, publicConfig)
import Record (merge)
import Type.Row (type (+))

type Config = { | InternalConfigRow + PublicConfigRow + () }

config :: Config
config = merge internalConfig publicConfig
