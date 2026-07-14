-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.NewEmail where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.NewEmail"

type NewEmail_ = "newEmail"

newEmail' = π :: Π NewEmail_
newEmail_ = ᴠ @NewEmail_ :: String
_newEmail = prop newEmail' :: ∀ a r. Lens' { newEmail :: a | r } a
