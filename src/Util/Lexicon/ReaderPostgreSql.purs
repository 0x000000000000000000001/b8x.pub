-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderPostgreSql where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderPostgreSql"

type ReaderPostgreSql_ = "readerPostgreSql"

readerPostgreSql' = π :: Π ReaderPostgreSql_
readerPostgreSql_ = ᴠ @ReaderPostgreSql_ :: String
_readerPostgreSql = prop readerPostgreSql' :: ∀ a r. Lens' { readerPostgreSql :: a | r } a
