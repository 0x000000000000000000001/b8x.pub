-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderMqConfig where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderMqConfig"

type ReaderMqConfig_ = "readerMqConfig"

readerMqConfig' = π :: Π ReaderMqConfig_
readerMqConfig_ = ᴠ @ReaderMqConfig_ :: String
_readerMqConfig = prop readerMqConfig' :: ∀ a r. Lens' { readerMqConfig :: a | r } a
