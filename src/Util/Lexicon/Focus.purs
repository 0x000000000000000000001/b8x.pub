-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Focus where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Focus"

type Focus_ = "focus"

focus' = π :: Π Focus_
focus_ = ᴠ @Focus_ :: String
_focus = prop focus' :: ∀ a r. Lens' { focus :: a | r } a
