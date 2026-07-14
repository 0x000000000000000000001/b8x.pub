-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Fit where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Fit"

type Fit_ = "fit"

fit' = π :: Π Fit_
fit_ = ᴠ @Fit_ :: String
_fit = prop fit' :: ∀ a r. Lens' { fit :: a | r } a
