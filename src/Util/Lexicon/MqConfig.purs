-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.MqConfig where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.MqConfig"

type MqConfig_ = "mqConfig"

mqConfig' = π :: Π MqConfig_
mqConfig_ = ᴠ @MqConfig_ :: String
_mqConfig = prop mqConfig' :: ∀ a r. Lens' { mqConfig :: a | r } a
