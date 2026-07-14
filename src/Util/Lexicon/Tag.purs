-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Tag where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Tag"

type Tag_ = "tag"

tag' = π :: Π Tag_
tag_ = ᴠ @Tag_ :: String
_tag = prop tag' :: ∀ a r. Lens' { tag :: a | r } a
