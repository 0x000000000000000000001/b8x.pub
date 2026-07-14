-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Prev where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Prev"

type Prev_ = "prev"

prev' = π :: Π Prev_
prev_ = ᴠ @Prev_ :: String
_prev = prop prev' :: ∀ a r. Lens' { prev :: a | r } a
