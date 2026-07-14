-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Input where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Input"

type Input_ = "input"

input' = π :: Π Input_
input_ = ᴠ @Input_ :: String
_input = prop input' :: ∀ a r. Lens' { input :: a | r } a
