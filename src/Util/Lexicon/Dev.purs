-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Dev where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Dev"

type Dev_ = "dev"

dev' = π :: Π Dev_
dev_ = ᴠ @Dev_ :: String
_dev = prop dev' :: ∀ a r. Lens' { dev :: a | r } a
