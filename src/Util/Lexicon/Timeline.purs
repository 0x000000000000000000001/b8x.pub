-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Timeline where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Timeline"

type Timeline_ = "timeline"

timeline' = π :: Π Timeline_
timeline_ = ᴠ @Timeline_ :: String
_timeline = prop timeline' :: ∀ a r. Lens' { timeline :: a | r } a
