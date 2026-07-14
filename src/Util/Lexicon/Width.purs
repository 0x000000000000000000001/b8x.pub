-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Width where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Width"

type Width_ = "width"

width' = π :: Π Width_
width_ = ᴠ @Width_ :: String
_width = prop width' :: ∀ a r. Lens' { width :: a | r } a
