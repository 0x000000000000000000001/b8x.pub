module Core.Mod.Author.Author where

import Util.Type.Type (class Reflect)

data Author

instance Reflect Author where
  reflectName = "Author"