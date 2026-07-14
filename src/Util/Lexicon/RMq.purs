-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.RMq where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.RMq"

type RMq_ = "rMq"

rMq' = π :: Π RMq_
rMq_ = ᴠ @RMq_ :: String
_rMq = prop rMq' :: ∀ a r. Lens' { rMq :: a | r } a
