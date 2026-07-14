-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderRMq where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderRMq"

type ReaderRMq_ = "readerRMq"

readerRMq' = π :: Π ReaderRMq_
readerRMq_ = ᴠ @ReaderRMq_ :: String
_readerRMq = prop readerRMq' :: ∀ a r. Lens' { readerRMq :: a | r } a
