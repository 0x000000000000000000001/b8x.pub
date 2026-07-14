module Util.Style.Image
  (ObjectFit
  , contain
  , cover
  , fill
  , objectFit
  , objectFitCover
  ) where

import Proem hiding (bottom, top)

import CSS as CSS
import Util.Style.Base (raw)

data ObjectFit
  = Contain
  | Cover
  | Fill

contain = Contain :: ObjectFit
cover = Cover :: ObjectFit
fill = Fill :: ObjectFit

objectFit :: ObjectFit -> CSS.CSS
objectFit fit = raw "object-fit" $ case fit of
  Contain -> "contain"
  Cover -> "cover"
  _ -> "fill"

objectFitCover :: CSS.CSS
objectFitCover = objectFit Cover
