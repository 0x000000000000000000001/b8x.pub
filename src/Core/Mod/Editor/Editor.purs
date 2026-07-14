module Core.Mod.Editor.Editor where

import Util.Type.Type (class Reflect)

data Editor

instance Reflect Editor where
  reflectName = "Editor"