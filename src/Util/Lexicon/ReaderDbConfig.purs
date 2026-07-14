-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderDbConfig where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderDbConfig"

type ReaderDbConfig_ = "readerDbConfig"

readerDbConfig' = π :: Π ReaderDbConfig_
readerDbConfig_ = ᴠ @ReaderDbConfig_ :: String
_readerDbConfig = prop readerDbConfig' :: ∀ a r. Lens' { readerDbConfig :: a | r } a
