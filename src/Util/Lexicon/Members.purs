-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Members where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Members"

type Members_ = "members"

members' = π :: Π Members_
members_ = ᴠ @Members_ :: String
_members = prop members' :: ∀ a r. Lens' { members :: a | r } a
