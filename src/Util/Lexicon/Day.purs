-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Day where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Day"

type Day_ = "day"

day' = π :: Π Day_
day_ = ᴠ @Day_ :: String
_day = prop day' :: ∀ a r. Lens' { day :: a | r } a
