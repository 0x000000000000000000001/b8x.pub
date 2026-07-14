module Core.Mod.Article.Illustrations.Message.Query.Opt where

import Proem

import Core.Message.Query.Payload (Need)
import Core.Mod.Image.Message.Query.Opt (ImageOpt, ImageInnerNeeds)
import Data.Maybe (Maybe)

type IllustrationsOpt =
  { priorizeRatio :: Maybe Number
  , fallbackToBookCovers :: Boolean
  }

type IllustrationsInnerNeeds =
  { image :: Need ImageOpt ImageInnerNeeds
  , caption :: Need Ɩ Ɩ
  , isFallback :: Need Ɩ Ɩ
  }
