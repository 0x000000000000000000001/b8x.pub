-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Portraits where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Portraits"

type Portraits_ = "portraits"

portraits' = π :: Π Portraits_
portraits_ = ᴠ @Portraits_ :: String
_portraits = prop portraits' :: ∀ a r. Lens' { portraits :: a | r } a
