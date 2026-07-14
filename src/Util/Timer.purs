module Util.Timer where

import Effect (Effect)
import Util.Unit (Ɩ)

foreign import data IntervalId :: Type

foreign import _setInterval :: Int -> Effect Ɩ -> Effect IntervalId

foreign import _clearInterval :: IntervalId -> Effect Ɩ
