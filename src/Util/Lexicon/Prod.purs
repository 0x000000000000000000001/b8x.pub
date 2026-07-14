-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Prod where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Prod"

type Prod_ = "prod"

prod' = π :: Π Prod_
prod_ = ᴠ @Prod_ :: String
_prod = prop prod' :: ∀ a r. Lens' { prod :: a | r } a
