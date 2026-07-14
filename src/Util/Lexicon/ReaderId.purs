-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderId where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderId"

type ReaderId_ = "readerId"

readerId' = π :: Π ReaderId_
readerId_ = ᴠ @ReaderId_ :: String
_readerId = prop readerId' :: ∀ a r. Lens' { readerId :: a | r } a
