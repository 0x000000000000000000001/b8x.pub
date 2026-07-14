-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Radius where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Radius"

type Radius_ = "radius"

radius' = π :: Π Radius_
radius_ = ᴠ @Radius_ :: String
_radius = prop radius' :: ∀ a r. Lens' { radius :: a | r } a
