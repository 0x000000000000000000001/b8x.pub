-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Month where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Month"

type Month_ = "month"

month' = π :: Π Month_
month_ = ᴠ @Month_ :: String
_month = prop month' :: ∀ a r. Lens' { month :: a | r } a
