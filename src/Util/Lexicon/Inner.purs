-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Inner where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Inner"

type Inner_ = "inner"

inner' = π :: Π Inner_
inner_ = ᴠ @Inner_ :: String
_inner = prop inner' :: ∀ a r. Lens' { inner :: a | r } a
