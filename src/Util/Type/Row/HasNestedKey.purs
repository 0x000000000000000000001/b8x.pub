module Util.Type.Row.HasNestedKey
  (class HasNestedKey
  , class HasNestedKeyLoop
  , class SplitDot
  , class SplitDotLoop
  , class SplitDotStep
  , class HasNestedKeys
  , class HasNestedKeysLoop
  ) where

import Prim.Row as Row
import Prim.RowList (class RowToList)
import Prim.RowList as RowList
import Prim.Symbol as Sym
import Util.Type.Record (class UnwrapRecord)

-- Record 

class HasNestedKey (record :: Type) (path :: Symbol) (val :: Type) | record path -> val

instance
  (SplitDot path l r
  , UnwrapRecord record row
  , HasNestedKeyLoop (Record row) l r val
  ) =>
  HasNestedKey record path val

class HasNestedKeyLoop (record :: Type) (l :: Symbol) (r :: Symbol) (val :: Type) | record l r -> val

instance
  Row.Cons l val _1 row =>
  HasNestedKeyLoop (Record row) l "" val
else instance
  (Row.Cons l nested _1 row
  , HasNestedKey nested r val
  ) =>
  HasNestedKeyLoop (Record row) l r val

class HasNestedKeys (sortRow :: Row Type) (indexRecord :: Type)

instance
  (RowToList sortRow sortList
  , HasNestedKeysLoop sortList indexRecord
  ) =>
  HasNestedKeys sortRow indexRecord

class HasNestedKeysLoop (sortList :: RowList.RowList Type) (indexRecord :: Type)

instance HasNestedKeysLoop RowList.Nil indexRecord

instance
  (HasNestedKey indexRecord key any
  , HasNestedKeysLoop tail indexRecord
  ) =>
  HasNestedKeysLoop (RowList.Cons key val tail) indexRecord

-- String

class SplitDot (s :: Symbol) (l :: Symbol) (r :: Symbol) | s -> l r, l r -> s

instance SplitDotLoop "" s l r => SplitDot s l r

class SplitDotLoop (acc :: Symbol) (s :: Symbol) (l :: Symbol) (r :: Symbol) | acc s -> l r

instance SplitDotLoop acc "" acc ""
else instance
  (Sym.Cons h t s
  , SplitDotStep h acc t l r
  ) =>
  SplitDotLoop acc s l r

class SplitDotStep (h :: Symbol) (acc :: Symbol) (t :: Symbol) (l :: Symbol) (r :: Symbol) | h acc t -> l r

instance SplitDotStep "." acc t acc t
else instance
  (Sym.Append acc h acc'
  , SplitDotLoop acc' t l r
  ) =>
  SplitDotStep h acc t l r
