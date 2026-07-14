-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.MalformedPayloadValue where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.MalformedPayloadValue"

type MalformedPayloadValue_ = "malformedPayloadValue"

malformedPayloadValue' = π :: Π MalformedPayloadValue_
malformedPayloadValue_ = ᴠ @MalformedPayloadValue_ :: String
_malformedPayloadValue = prop malformedPayloadValue' :: ∀ a r. Lens' { malformedPayloadValue :: a | r } a
