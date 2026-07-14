-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Persons where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Persons"

type Persons_ = "persons"

persons' = π :: Π Persons_
persons_ = ᴠ @Persons_ :: String
_persons = prop persons' :: ∀ a r. Lens' { persons :: a | r } a
