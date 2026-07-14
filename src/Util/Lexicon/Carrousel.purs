-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Carrousel where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Carrousel"

type Carrousel_ = "carrousel"

carrousel' = π :: Π Carrousel_
carrousel_ = ᴠ @Carrousel_ :: String
_carrousel = prop carrousel' :: ∀ a r. Lens' { carrousel :: a | r } a
