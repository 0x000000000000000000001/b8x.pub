module Util.Lexicon.X where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.X"

type X_ = "x"

x' = π :: Π X_
x_ = ᴠ @X_ :: String
_x = prop x' :: ∀ a r. Lens' { x :: a | r } a
