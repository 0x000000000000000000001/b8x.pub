module Core.Mod.Article.Article where

import Util.Type.Type (class Reflect)

data Article

instance Reflect Article where
  reflectName = "Article"