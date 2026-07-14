-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Border where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Border"

type Border_ = "border"

border' = π :: Π Border_
border_ = ᴠ @Border_ :: String
_border = prop border' :: ∀ a r. Lens' { border :: a | r } a
