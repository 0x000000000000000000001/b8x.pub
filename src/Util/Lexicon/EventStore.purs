-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.EventStore where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.EventStore"

type EventStore_ = "eventStore"

eventStore' = π :: Π EventStore_
eventStore_ = ᴠ @EventStore_ :: String
_eventStore = prop eventStore' :: ∀ a r. Lens' { eventStore :: a | r } a
