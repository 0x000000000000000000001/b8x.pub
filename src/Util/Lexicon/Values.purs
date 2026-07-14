-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Values where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Values"

type Values_ = "values"

values' = π :: Π Values_
values_ = ᴠ @Values_ :: String
_values = prop values' :: ∀ a r. Lens' { values :: a | r } a
