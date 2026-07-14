-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Hover where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Hover"

type Hover_ = "hover"

hover' = π :: Π Hover_
hover_ = ᴠ @Hover_ :: String
_hover = prop hover' :: ∀ a r. Lens' { hover :: a | r } a
