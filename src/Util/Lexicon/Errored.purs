-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Errored where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Errored"

type Errored_ = "errored"

errored' = π :: Π Errored_
errored_ = ᴠ @Errored_ :: String
_errored = prop errored' :: ∀ a r. Lens' { errored :: a | r } a
