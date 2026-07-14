-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.Payload where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.Payload"

type Payload_ = "payload"

payload' = π :: Π Payload_
payload_ = ᴠ @Payload_ :: String
_payload = prop payload' :: ∀ a r. Lens' { payload :: a | r } a
