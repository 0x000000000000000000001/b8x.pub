-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.SectionDescription where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.SectionDescription"

type SectionDescription_ = "sectionDescription"

sectionDescription' = π :: Π SectionDescription_
sectionDescription_ = ᴠ @SectionDescription_ :: String
_sectionDescription = prop sectionDescription' :: ∀ a r. Lens' { sectionDescription :: a | r } a
