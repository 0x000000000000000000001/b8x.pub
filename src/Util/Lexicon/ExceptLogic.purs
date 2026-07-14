-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ExceptLogic where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ExceptLogic"

type ExceptLogic_ = "exceptLogic"

exceptLogic' = π :: Π ExceptLogic_
exceptLogic_ = ᴠ @ExceptLogic_ :: String
_exceptLogic = prop exceptLogic' :: ∀ a r. Lens' { exceptLogic :: a | r } a
