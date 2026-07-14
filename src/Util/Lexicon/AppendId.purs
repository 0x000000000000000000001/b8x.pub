-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.AppendId where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.AppendId"

type AppendId_ = "appendId"

appendId' = π :: Π AppendId_
appendId_ = ᴠ @AppendId_ :: String
_appendId = prop appendId' :: ∀ a r. Lens' { appendId :: a | r } a
