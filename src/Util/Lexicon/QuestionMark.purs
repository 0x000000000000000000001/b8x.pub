-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.QuestionMark where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.QuestionMark"

type QuestionMark_ = "questionMark"

questionMark' = π :: Π QuestionMark_
questionMark_ = ᴠ @QuestionMark_ :: String
_questionMark = prop questionMark' :: ∀ a r. Lens' { questionMark :: a | r } a
