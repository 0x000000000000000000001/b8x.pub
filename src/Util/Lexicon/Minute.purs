-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Minute where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Minute"

type Minute_ = "minute"

minute' = π :: Π Minute_
minute_ = ᴠ @Minute_ :: String
_minute = prop minute' :: ∀ a r. Lens' { minute :: a | r } a
