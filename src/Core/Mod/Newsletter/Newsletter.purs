module Core.Mod.Newsletter.Newsletter where

import Util.Type.Type (class Reflect)

data Newsletter

instance Reflect Newsletter where
  reflectName = "Newsletter"
