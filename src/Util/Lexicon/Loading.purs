-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Loading where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Loading"

type Loading_ = "loading"

loading' = π :: Π Loading_
loading_ = ᴠ @Loading_ :: String
_loading = prop loading' :: ∀ a r. Lens' { loading :: a | r } a
