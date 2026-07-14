-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Modal where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Modal"

type Modal_ = "modal"

modal' = π :: Π Modal_
modal_ = ᴠ @Modal_ :: String
_modal = prop modal' :: ∀ a r. Lens' { modal :: a | r } a
