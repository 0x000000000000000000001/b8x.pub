-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Id where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Id"

type Id_ = "id"

id' = π :: Π Id_
id_ = ᴠ @Id_ :: String
_id = prop id' :: ∀ a r. Lens' { id :: a | r } a
