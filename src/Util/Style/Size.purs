module Util.Style.Size where

import Proem hiding (bottom, top)

import CSS (Size) as CSS
import CSS (pct, rem, px)
import CSS.Common (auto)
import Effect (Effect)
import Util.Type.String.ToString (class ToString)

foreign import _getRootFontSize :: Effect Number

data Size
  = Pct Number
  | Rem Number
  | Px Number
  | Auto

applyToSize :: ∀ a. (∀ u. CSS.Size u -> a) -> Size -> a
applyToSize f = case _ of
  Pct p -> f (pct p)
  Rem r -> f (rem r)
  Px p' -> f (px p')
  _ -> f auto

instance ToString Size where
  toString = case _ of
    Px p -> show p <> "px"
    Pct p -> show p <> "%"
    Rem r -> show r <> "rem"
    Auto -> "auto"
