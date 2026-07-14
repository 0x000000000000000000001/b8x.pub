-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Projection where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Projection"

type Projection_ = "projection"

projection' = π :: Π Projection_
projection_ = ᴠ @Projection_ :: String
_projection = prop projection' :: ∀ a r. Lens' { projection :: a | r } a
