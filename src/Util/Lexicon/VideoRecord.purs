-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.VideoRecord where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.VideoRecord"

type VideoRecord_ = "videoRecord"

videoRecord' = π :: Π VideoRecord_
videoRecord_ = ᴠ @VideoRecord_ :: String
_videoRecord = prop videoRecord' :: ∀ a r. Lens' { videoRecord :: a | r } a
