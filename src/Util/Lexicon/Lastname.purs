-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Lastname where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Lastname"

type Lastname_ = "lastname"

lastname' = π :: Π Lastname_
lastname_ = ᴠ @Lastname_ :: String
_lastname = prop lastname' :: ∀ a r. Lens' { lastname :: a | r } a
