-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderAlreadyRegistered where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderAlreadyRegistered"

type ReaderAlreadyRegistered_ = "readerAlreadyRegistered"

readerAlreadyRegistered' = π :: Π ReaderAlreadyRegistered_
readerAlreadyRegistered_ = ᴠ @ReaderAlreadyRegistered_ :: String
_readerAlreadyRegistered = prop readerAlreadyRegistered' :: ∀ a r. Lens' { readerAlreadyRegistered :: a | r } a
