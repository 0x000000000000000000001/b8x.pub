-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Event where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Event"

type Event_ = "event"

event' = π :: Π Event_
event_ = ᴠ @Event_ :: String
_event = prop event' :: ∀ a r. Lens' { event :: a | r } a
