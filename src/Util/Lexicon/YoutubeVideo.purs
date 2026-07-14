-- 
-- Auto-generated.
-- Do not edit. Edit Inter.Cli.CodeGen.Lexicon
--
module Util.Lexicon.YoutubeVideo where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)

fullModuleName :: String
fullModuleName = "Util.Lexicon.YoutubeVideo"

type YoutubeVideo_ = "youtubeVideo"

youtubeVideo' = π :: Π YoutubeVideo_
youtubeVideo_ = ᴠ @YoutubeVideo_ :: String
_youtubeVideo = prop youtubeVideo' :: ∀ a r. Lens' { youtubeVideo :: a | r } a
