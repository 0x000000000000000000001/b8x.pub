-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Vault where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Vault"

type Vault_ = "vault"

vault' = π :: Π Vault_
vault_ = ᴠ @Vault_ :: String
_vault = prop vault' :: ∀ a r. Lens' { vault :: a | r } a
