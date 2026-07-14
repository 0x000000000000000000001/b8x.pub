-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.RabbitMq where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.RabbitMq"

type RabbitMq_ = "rabbitMq"

rabbitMq' = π :: Π RabbitMq_
rabbitMq_ = ᴠ @RabbitMq_ :: String
_rabbitMq = prop rabbitMq' :: ∀ a r. Lens' { rabbitMq :: a | r } a
