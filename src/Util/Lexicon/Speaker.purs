-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Speaker where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Speaker"

type Speaker_ = "speaker"

speaker' = π :: Π Speaker_
speaker_ = ᴠ @Speaker_ :: String
_speaker = prop speaker' :: ∀ a r. Lens' { speaker :: a | r } a
