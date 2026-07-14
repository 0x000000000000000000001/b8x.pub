-- Useful to build registries from rows.
-- That lets us have behaviours that are well-known in dynamic languages (e.g. dynamic FQCN import).
module Util.Type.Row.Registry where

import Foreign.Object (Object)
import Foreign.Object as Object
import Prim.RowList (class RowToList, RowList, Nil)

class RegistryBuilder (name :: Type) (rl :: RowList Type) (out :: Type) | name rl -> out where
  buildRegistryFromRowList :: Object out

instance RegistryBuilder name Nil out where
  buildRegistryFromRowList = Object.empty

buildRegistry :: ∀ @name @r @out rl. RowToList r rl => RegistryBuilder name rl out => Object out
buildRegistry = buildRegistryFromRowList @name @rl @out
