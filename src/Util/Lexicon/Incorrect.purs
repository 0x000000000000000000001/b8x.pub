-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Incorrect where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Incorrect"

type Incorrect_ = "incorrect"

incorrect' = π :: Π Incorrect_
incorrect_ = ᴠ @Incorrect_ :: String
_incorrect = prop incorrect' :: ∀ a r. Lens' { incorrect :: a | r } a
