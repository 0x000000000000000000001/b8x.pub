module Util.Type.Record where

import Data.Newtype (class Newtype)
import Data.Maybe (Maybe)

-- | Get the row inside a record (or a wrapped record).
class UnwrapRecord (t :: Type) (r :: Row Type) | t -> r

instance UnwrapRecord (Record r) r
else instance UnwrapRecord t r => UnwrapRecord (Maybe t) r
else instance Newtype t (Record r) => UnwrapRecord t r
