-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Person where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Person"

type Person_ = "person"

person' = π :: Π Person_
person_ = ᴠ @Person_ :: String
_person = prop person' :: ∀ a r. Lens' { person :: a | r } a
