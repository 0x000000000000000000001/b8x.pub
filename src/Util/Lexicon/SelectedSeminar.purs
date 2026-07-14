-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.SelectedSeminar where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.SelectedSeminar"

type SelectedSeminar_ = "selectedSeminar"

selectedSeminar' = π :: Π SelectedSeminar_
selectedSeminar_ = ᴠ @SelectedSeminar_ :: String
_selectedSeminar = prop selectedSeminar' :: ∀ a r. Lens' { selectedSeminar :: a | r } a
