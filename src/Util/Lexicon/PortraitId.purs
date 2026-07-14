-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.PortraitId where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.PortraitId"

type PortraitId_ = "portraitId"

portraitId' = π :: Π PortraitId_
portraitId_ = ᴠ @PortraitId_ :: String
_portraitId = prop portraitId' :: ∀ a r. Lens' { portraitId :: a | r } a
