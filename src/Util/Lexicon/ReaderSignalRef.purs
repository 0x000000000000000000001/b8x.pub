-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderSignalRef where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderSignalRef"

type ReaderSignalRef_ = "readerSignalRef"

readerSignalRef' = π :: Π ReaderSignalRef_
readerSignalRef_ = ᴠ @ReaderSignalRef_ :: String
_readerSignalRef = prop readerSignalRef' :: ∀ a r. Lens' { readerSignalRef :: a | r } a
