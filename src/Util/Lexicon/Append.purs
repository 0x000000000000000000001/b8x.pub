-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Append where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Append"

type Append_ = "append"

append' = π :: Π Append_
append_ = ᴠ @Append_ :: String
_append = prop append' :: ∀ a r. Lens' { append :: a | r } a
