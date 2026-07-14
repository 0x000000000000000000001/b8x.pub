-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.VideoUrl where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.VideoUrl"

type VideoUrl_ = "videoUrl"

videoUrl' = π :: Π VideoUrl_
videoUrl_ = ᴠ @VideoUrl_ :: String
_videoUrl = prop videoUrl' :: ∀ a r. Lens' { videoUrl :: a | r } a
