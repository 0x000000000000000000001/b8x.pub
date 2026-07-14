-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.TestId where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.TestId"

type TestId_ = "testId"

testId' = π :: Π TestId_
testId_ = ᴠ @TestId_ :: String
_testId = prop testId' :: ∀ a r. Lens' { testId :: a | r } a
