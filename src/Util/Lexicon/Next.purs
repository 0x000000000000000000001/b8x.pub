-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Next where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Next"

type Next_ = "next"

next' = π :: Π Next_
next_ = ᴠ @Next_ :: String
_next = prop next' :: ∀ a r. Lens' { next :: a | r } a
