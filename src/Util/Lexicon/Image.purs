-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Image where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Image"

type Image_ = "image"

image' = π :: Π Image_
image_ = ᴠ @Image_ :: String
_image = prop image' :: ∀ a r. Lens' { image :: a | r } a
