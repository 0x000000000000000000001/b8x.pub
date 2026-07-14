-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Theme where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Theme"

type Theme_ = "theme"

theme' = π :: Π Theme_
theme_ = ᴠ @Theme_ :: String
_theme = prop theme' :: ∀ a r. Lens' { theme :: a | r } a
