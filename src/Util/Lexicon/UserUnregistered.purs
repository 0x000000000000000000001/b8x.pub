-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.UserUnregistered where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.UserUnregistered"

type UserUnregistered_ = "userUnregistered"

userUnregistered' = π :: Π UserUnregistered_
userUnregistered_ = ᴠ @UserUnregistered_ :: String
_userUnregistered = prop userUnregistered' :: ∀ a r. Lens' { userUnregistered :: a | r } a
