-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Collaborators where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Collaborators"

type Collaborators_ = "collaborators"

collaborators' = π :: Π Collaborators_
collaborators_ = ᴠ @Collaborators_ :: String
_collaborators = prop collaborators' :: ∀ a r. Lens' { collaborators :: a | r } a
