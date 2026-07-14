-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Queue where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Queue"

type Queue_ = "queue"

queue' = π :: Π Queue_
queue_ = ᴠ @Queue_ :: String
_queue = prop queue' :: ∀ a r. Lens' { queue :: a | r } a
