-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Email where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Email"

type Email_ = "email"

email' = π :: Π Email_
email_ = ᴠ @Email_ :: String
_email = prop email' :: ∀ a r. Lens' { email :: a | r } a
