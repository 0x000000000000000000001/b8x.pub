-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Stage where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Stage"

type Stage_ = "stage"

stage' = π :: Π Stage_
stage_ = ᴠ @Stage_ :: String
_stage = prop stage' :: ∀ a r. Lens' { stage :: a | r } a
