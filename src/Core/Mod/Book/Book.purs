module Core.Mod.Book.Book where

import Util.Type.Type (class Reflect)

data Book

instance Reflect Book where
  reflectName = "Book"