-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Left where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Left"

type Left_ = "left"

left' = π :: Π Left_
left_ = ᴠ @Left_ :: String
_left = prop left' :: ∀ a r. Lens' { left :: a | r } a
