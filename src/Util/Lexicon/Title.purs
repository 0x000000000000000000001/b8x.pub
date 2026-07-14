-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Title where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Title"

type Title_ = "title"

title' = π :: Π Title_
title_ = ᴠ @Title_ :: String
_title = prop title' :: ∀ a r. Lens' { title :: a | r } a
