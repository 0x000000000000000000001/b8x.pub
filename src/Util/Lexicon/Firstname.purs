-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Firstname where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Firstname"

type Firstname_ = "firstname"

firstname' = π :: Π Firstname_
firstname_ = ᴠ @Firstname_ :: String
_firstname = prop firstname' :: ∀ a r. Lens' { firstname :: a | r } a
