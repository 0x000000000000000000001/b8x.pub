-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Items where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Items"

type Items_ = "items"

items' = π :: Π Items_
items_ = ᴠ @Items_ :: String
_items = prop items' :: ∀ a r. Lens' { items :: a | r } a
