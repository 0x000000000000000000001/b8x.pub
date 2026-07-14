-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.UserNotRegistered where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.UserNotRegistered"

type UserNotRegistered_ = "userNotRegistered"

userNotRegistered' = π :: Π UserNotRegistered_
userNotRegistered_ = ᴠ @UserNotRegistered_ :: String
_userNotRegistered = prop userNotRegistered' :: ∀ a r. Lens' { userNotRegistered :: a | r } a
