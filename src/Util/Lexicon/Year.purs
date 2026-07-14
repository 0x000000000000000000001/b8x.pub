-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Year where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Year"

type Year_ = "year"

year' = π :: Π Year_
year_ = ᴠ @Year_ :: String
_year = prop year' :: ∀ a r. Lens' { year :: a | r } a
