-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.ReaderPSql where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.ReaderPSql"

type ReaderPSql_ = "readerPSql"

readerPSql' = π :: Π ReaderPSql_
readerPSql_ = ᴠ @ReaderPSql_ :: String
_readerPSql = prop readerPSql' :: ∀ a r. Lens' { readerPSql :: a | r } a
