module Inter.Cli.Util.KeepAlive where

import Effect (Effect)
import Prelude (Unit)

foreign import keepMainAlive :: Effect Unit
