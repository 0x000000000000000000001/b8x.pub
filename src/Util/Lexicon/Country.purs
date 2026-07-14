-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Country where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Country"

type Country_ = "country"

country' = π :: Π Country_
country_ = ᴠ @Country_ :: String
_country = prop country' :: ∀ a r. Lens' { country :: a | r } a
