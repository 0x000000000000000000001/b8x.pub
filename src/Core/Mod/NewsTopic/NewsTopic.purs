module Core.Mod.NewsTopic.NewsTopic where

import Util.Type.Type (class Reflect)

data NewsTopic

instance Reflect NewsTopic where
  reflectName = "NewsTopic"