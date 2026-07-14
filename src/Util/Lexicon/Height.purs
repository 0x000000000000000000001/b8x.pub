-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Height where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Height"

type Height_ = "height"

height' = π :: Π Height_
height_ = ᴠ @Height_ :: String
_height = prop height' :: ∀ a r. Lens' { height :: a | r } a
