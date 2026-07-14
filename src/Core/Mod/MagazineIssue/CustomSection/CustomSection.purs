module Core.Mod.MagazineIssue.CustomSection.CustomSection where

import Util.Type.Type (class Reflect)

data CustomSection

instance Reflect CustomSection where
  reflectName = "CustomSection"
