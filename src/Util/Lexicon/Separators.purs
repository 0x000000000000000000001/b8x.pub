-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Separators where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Separators"

type Separators_ = "separators"

separators' = π :: Π Separators_
separators_ = ᴠ @Separators_ :: String
_separators = prop separators' :: ∀ a r. Lens' { separators :: a | r } a
