-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.About where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.About"

type About_ = "about"

about' = π :: Π About_
about_ = ᴠ @About_ :: String
_about = prop about' :: ∀ a r. Lens' { about :: a | r } a
