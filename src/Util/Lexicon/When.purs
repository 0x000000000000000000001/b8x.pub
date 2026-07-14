-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.When where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.When"

type When_ = "when"

when' = π :: Π When_
when_ = ᴠ @When_ :: String
_when = prop when' :: ∀ a r. Lens' { when :: a | r } a
