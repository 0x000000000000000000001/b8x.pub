-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.With where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.With"

type With_ = "with"

with' = π :: Π With_
with_ = ᴠ @With_ :: String
_with = prop with' :: ∀ a r. Lens' { with :: a | r } a
