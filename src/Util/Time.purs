module Util.Time
  (unsafeDate
  )
  where

import Prelude

import Data.Date (Date, canonicalDate)
import Data.Enum (toEnum)
import Data.Maybe (fromJust)
import Partial.Unsafe (unsafePartial)

unsafeDate :: Int -> Int -> Int -> Date
unsafeDate y m d = 
  unsafePartial $
    canonicalDate
      (y # toEnum # fromJust)
      (m # toEnum # fromJust)
      (d # toEnum # fromJust)