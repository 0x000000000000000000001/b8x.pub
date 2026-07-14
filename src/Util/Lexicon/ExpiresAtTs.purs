-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ExpiresAtTs where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ExpiresAtTs"

type ExpiresAtTs_ = "expiresAtTs"

expiresAtTs' = π :: Π ExpiresAtTs_
expiresAtTs_ = ᴠ @ExpiresAtTs_ :: String
_expiresAtTs = prop expiresAtTs' :: ∀ a r. Lens' { expiresAtTs :: a | r } a
