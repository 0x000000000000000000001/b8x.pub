-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Test where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Test"

type Test_ = "test"

test' = π :: Π Test_
test_ = ᴠ @Test_ :: String
_test = prop test' :: ∀ a r. Lens' { test :: a | r } a
