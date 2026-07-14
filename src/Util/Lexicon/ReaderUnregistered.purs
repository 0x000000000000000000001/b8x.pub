-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderUnregistered where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderUnregistered"

type ReaderUnregistered_ = "readerUnregistered"

readerUnregistered' = π :: Π ReaderUnregistered_
readerUnregistered_ = ᴠ @ReaderUnregistered_ :: String
_readerUnregistered = prop readerUnregistered' :: ∀ a r. Lens' { readerUnregistered :: a | r } a
