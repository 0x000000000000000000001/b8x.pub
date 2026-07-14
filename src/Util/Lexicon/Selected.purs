-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Selected where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Selected"

type Selected_ = "selected"

selected' = π :: Π Selected_
selected_ = ᴠ @Selected_ :: String
_selected = prop selected' :: ∀ a r. Lens' { selected :: a | r } a
