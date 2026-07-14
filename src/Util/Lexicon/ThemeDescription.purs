-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ThemeDescription where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ThemeDescription"

type ThemeDescription_ = "themeDescription"

themeDescription' = π :: Π ThemeDescription_
themeDescription_ = ᴠ @ThemeDescription_ :: String
_themeDescription = prop themeDescription' :: ∀ a r. Lens' { themeDescription :: a | r } a
