-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Tooltip where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Tooltip"

type Tooltip_ = "tooltip"

tooltip' = π :: Π Tooltip_
tooltip_ = ᴠ @Tooltip_ :: String
_tooltip = prop tooltip' :: ∀ a r. Lens' { tooltip :: a | r } a
