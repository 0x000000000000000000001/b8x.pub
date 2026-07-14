-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Find where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Find"

type Find_ = "find"

find' = π :: Π Find_
find_ = ᴠ @Find_ :: String
_find = prop find' :: ∀ a r. Lens' { find :: a | r } a
