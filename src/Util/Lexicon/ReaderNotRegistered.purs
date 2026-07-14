-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderNotRegistered where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderNotRegistered"

type ReaderNotRegistered_ = "readerNotRegistered"

readerNotRegistered' = π :: Π ReaderNotRegistered_
readerNotRegistered_ = ᴠ @ReaderNotRegistered_ :: String
_readerNotRegistered = prop readerNotRegistered' :: ∀ a r. Lens' { readerNotRegistered :: a | r } a
