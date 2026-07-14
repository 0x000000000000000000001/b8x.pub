-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.UserId where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.UserId"

type UserId_ = "userId"

userId' = π :: Π UserId_
userId_ = ᴠ @UserId_ :: String
_userId = prop userId' :: ∀ a r. Lens' { userId :: a | r } a
