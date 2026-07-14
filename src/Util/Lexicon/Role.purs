-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Role where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Role"

type Role_ = "role"

role' = π :: Π Role_
role_ = ᴠ @Role_ :: String
_role = prop role' :: ∀ a r. Lens' { role :: a | r } a
