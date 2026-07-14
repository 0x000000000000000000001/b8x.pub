module Util.Runtime
  (isNode
  , isBrowser
  ) where

import Proem

foreign import _isNode :: Boolean

isNode :: Boolean
isNode = _isNode

isBrowser :: Boolean
isBrowser = not _isNode
