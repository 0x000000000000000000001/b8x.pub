-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.UserAlreadyRegistered where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.UserAlreadyRegistered"

type UserAlreadyRegistered_ = "userAlreadyRegistered"

userAlreadyRegistered' = π :: Π UserAlreadyRegistered_
userAlreadyRegistered_ = ᴠ @UserAlreadyRegistered_ :: String
_userAlreadyRegistered = prop userAlreadyRegistered' :: ∀ a r. Lens' { userAlreadyRegistered :: a | r } a
