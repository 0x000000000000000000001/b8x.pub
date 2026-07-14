-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Phone where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Phone"

type Phone_ = "phone"

phone' = π :: Π Phone_
phone_ = ᴠ @Phone_ :: String
_phone = prop phone' :: ∀ a r. Lens' { phone :: a | r } a
