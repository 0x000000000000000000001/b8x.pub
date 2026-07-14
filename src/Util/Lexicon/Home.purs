-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Home where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Home"

type Home_ = "home"

home' = π :: Π Home_
home_ = ᴠ @Home_ :: String
_home = prop home' :: ∀ a r. Lens' { home :: a | r } a
