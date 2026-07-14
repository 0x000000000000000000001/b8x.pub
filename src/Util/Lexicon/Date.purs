-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Date where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Date"

type Date_ = "date"

date' = π :: Π Date_
date_ = ᴠ @Date_ :: String
_date = prop date' :: ∀ a r. Lens' { date :: a | r } a
