-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Phase where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Phase"

type Phase_ = "phase"

phase' = π :: Π Phase_
phase_ = ᴠ @Phase_ :: String
_phase = prop phase' :: ∀ a r. Lens' { phase :: a | r } a
