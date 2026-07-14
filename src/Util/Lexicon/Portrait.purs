-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Portrait where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Portrait"

type Portrait_ = "portrait"

portrait' = π :: Π Portrait_
portrait_ = ᴠ @Portrait_ :: String
_portrait = prop portrait' :: ∀ a r. Lens' { portrait :: a | r } a
