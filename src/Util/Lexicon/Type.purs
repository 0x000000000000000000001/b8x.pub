-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Type where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Type"

type Type_ = "type"

type' = π :: Π Type_
type_ = ᴠ @Type_ :: String
_type = prop type' :: ∀ a r. Lens' { type :: a | r } a
