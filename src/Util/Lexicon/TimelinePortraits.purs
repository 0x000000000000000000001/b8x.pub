-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.TimelinePortraits where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.TimelinePortraits"

type TimelinePortraits_ = "timelinePortraits"

timelinePortraits' = π :: Π TimelinePortraits_
timelinePortraits_ = ᴠ @TimelinePortraits_ :: String
_timelinePortraits = prop timelinePortraits' :: ∀ a r. Lens' { timelinePortraits :: a | r } a
