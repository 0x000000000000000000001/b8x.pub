-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Right where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Right"

type Right_ = "right"

right' = π :: Π Right_
right_ = ᴠ @Right_ :: String
_right = prop right' :: ∀ a r. Lens' { right :: a | r } a
