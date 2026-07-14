-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Menu where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Menu"

type Menu_ = "menu"

menu' = π :: Π Menu_
menu_ = ᴠ @Menu_ :: String
_menu = prop menu' :: ∀ a r. Lens' { menu :: a | r } a
