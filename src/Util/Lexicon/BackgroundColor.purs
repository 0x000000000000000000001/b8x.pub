-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.BackgroundColor where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.BackgroundColor"

type BackgroundColor_ = "backgroundColor"

backgroundColor' = π :: Π BackgroundColor_
backgroundColor_ = ᴠ @BackgroundColor_ :: String
_backgroundColor = prop backgroundColor' :: ∀ a r. Lens' { backgroundColor :: a | r } a
