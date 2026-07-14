-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Seminars where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Seminars"

type Seminars_ = "seminars"

seminars' = π :: Π Seminars_
seminars_ = ᴠ @Seminars_ :: String
_seminars = prop seminars' :: ∀ a r. Lens' { seminars :: a | r } a
