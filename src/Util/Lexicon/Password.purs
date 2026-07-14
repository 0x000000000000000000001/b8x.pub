-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Password where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Password"

type Password_ = "password"

password' = π :: Π Password_
password_ = ᴠ @Password_ :: String
_password = prop password' :: ∀ a r. Lens' { password :: a | r } a
