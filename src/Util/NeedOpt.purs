module Util.NeedOpt where

import Prelude
import Yoga.JSON (class WriteForeign, class ReadForeign, writeImpl, readImpl)
import Foreign (Foreign, ForeignError(..), fail, F)

foreign import jsonNull :: Foreign
foreign import isNull :: Foreign -> Boolean

class WriteNeedOpt a where
  writeNeedOpt :: a -> Foreign

instance WriteNeedOpt Unit where
  writeNeedOpt _ = jsonNull
else instance WriteForeign a => WriteNeedOpt a where
  writeNeedOpt = writeImpl

class ReadNeedOpt a where
  readNeedOpt :: Foreign -> F a

instance ReadNeedOpt Unit where
  readNeedOpt f = if isNull f then pure unit else fail (ForeignError "Expected null for Unit")
else instance ReadForeign a => ReadNeedOpt a where
  readNeedOpt = readImpl
