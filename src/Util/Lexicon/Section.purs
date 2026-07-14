-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Section where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Section"

type Section_ = "section"

section' = π :: Π Section_
section_ = ᴠ @Section_ :: String
_section = prop section' :: ∀ a r. Lens' { section :: a | r } a
