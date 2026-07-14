-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Loaded where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Loaded"

type Loaded_ = "loaded"

loaded' = π :: Π Loaded_
loaded_ = ᴠ @Loaded_ :: String
_loaded = prop loaded' :: ∀ a r. Lens' { loaded :: a | r } a
