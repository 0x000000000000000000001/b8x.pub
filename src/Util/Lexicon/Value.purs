-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Value where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Value"

type Value_ = "value"

value' = π :: Π Value_
value_ = ᴠ @Value_ :: String
_value = prop value' :: ∀ a r. Lens' { value :: a | r } a
