-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Dispatch where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Dispatch"

type Dispatch_ = "dispatch"

dispatch' = π :: Π Dispatch_
dispatch_ = ᴠ @Dispatch_ :: String
_dispatch = prop dispatch' :: ∀ a r. Lens' { dispatch :: a | r } a
