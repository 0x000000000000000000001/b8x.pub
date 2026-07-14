-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderRabbitMq where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderRabbitMq"

type ReaderRabbitMq_ = "readerRabbitMq"

readerRabbitMq' = π :: Π ReaderRabbitMq_
readerRabbitMq_ = ᴠ @ReaderRabbitMq_ :: String
_readerRabbitMq = prop readerRabbitMq' :: ∀ a r. Lens' { readerRabbitMq :: a | r } a
