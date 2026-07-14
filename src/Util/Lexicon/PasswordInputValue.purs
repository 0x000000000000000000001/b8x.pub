-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.PasswordInputValue where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.PasswordInputValue"

type PasswordInputValue_ = "passwordInputValue"

passwordInputValue' = π :: Π PasswordInputValue_
passwordInputValue_ = ᴠ @PasswordInputValue_ :: String
_passwordInputValue = prop passwordInputValue' :: ∀ a r. Lens' { passwordInputValue :: a | r } a
