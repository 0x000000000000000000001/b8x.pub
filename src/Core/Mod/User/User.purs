module Core.Mod.User.User where

import Util.Type.Type (class Reflect)

data User

instance Reflect User where
  reflectName = "User"