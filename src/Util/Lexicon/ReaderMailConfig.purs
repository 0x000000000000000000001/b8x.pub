module Util.Lexicon.ReaderMailConfig where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

type ReaderMailConfig_ = "readerMailConfig"

readerMailConfig' = π :: Π ReaderMailConfig_
readerMailConfig_ = ᴠ @ReaderMailConfig_ :: String

_readerMailConfig = prop readerMailConfig' :: ∀ a r. Lens' { readerMailConfig :: a | r } a
