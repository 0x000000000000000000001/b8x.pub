-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Root where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Root"

type Root_ = "root"

root' = π :: Π Root_
root_ = ᴠ @Root_ :: String
_root = prop root' :: ∀ a r. Lens' { root :: a | r } a
