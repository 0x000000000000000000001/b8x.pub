-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.PSql where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.PSql"

type PSql_ = "pSql"

pSql' = π :: Π PSql_
pSql_ = ᴠ @PSql_ :: String
_pSql = prop pSql' :: ∀ a r. Lens' { pSql :: a | r } a
