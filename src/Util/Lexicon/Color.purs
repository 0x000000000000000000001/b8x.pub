-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Color where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Color"

type Color_ = "color"

color' = π :: Π Color_
color_ = ᴠ @Color_ :: String
_color = prop color' :: ∀ a r. Lens' { color :: a | r } a
