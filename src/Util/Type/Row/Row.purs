module Util.Type.Row.Row
  (class RecordKeysMatch
  , class RecordKeysOverlap
  , class RowKeysMatch
  , class RowKeysOverlap
  , class RowListKeysOverlap
  , recordKeysMatch
  , recordKeysOverlap
  , rowKeysMatch
  , rowKeysOverlap
  , class ExtractRowKeys
  , class ExtractRowListKeys
  , extractRowKeys
  , extractRowListKeys
  , class InRow
  , class InRowList
  ) where

import Proem

import Prim.Row as Row
import Prim.RowList (class RowToList, Cons, Nil, RowList)
import Util.Type.Quote (constraintPredicate)
import Data.Symbol (class IsSymbol)

-- | When you cannot hold the constraint with an instance.
-- | E.g. 
-- |
-- | check :: Q ConstraintPredicate
-- | check = recordKeysMatch @Payload @Fields
recordKeysMatch :: ∀ @t1 @t2. RecordKeysMatch t1 t2 => Q ConstraintPredicate
recordKeysMatch = η constraintPredicate

-- | Similar to recordKeysMatch, but with an inequality: 1 < 2
recordKeysOverlap :: ∀ @t1 @t2. RecordKeysOverlap t1 t2 => Q ConstraintPredicate
recordKeysOverlap = η constraintPredicate

-- | Similar to recordKeysMatch, but without the Record wraps.
rowKeysMatch :: ∀ @t1 @t2. RowKeysMatch t1 t2 => Q ConstraintPredicate
rowKeysMatch = η constraintPredicate

-- | Similar to rowKeysMatch, but with an inequality: 1 < 2
rowKeysOverlap :: ∀ @t1 @t2. RowKeysOverlap t1 t2 => Q ConstraintPredicate
rowKeysOverlap = η constraintPredicate

class RecordKeysMatch (r1 :: Type) (r2 :: Type)

instance
  (RowKeysOverlap r1 r2
  , RowKeysOverlap r2 r1
  ) =>
  RecordKeysMatch (Record r1) (Record r2)

class RowKeysMatch (r1 :: Row Type) (r2 :: Row Type)

instance
  (RowKeysOverlap r1 r2
  , RowKeysOverlap r2 r1
  ) =>
  RowKeysMatch r1 r2

class RecordKeysOverlap (r1 :: Type) (r2 :: Type)

instance
  (RowToList r1 rl1
  , RowListKeysOverlap rl1 r2
  ) =>
  RecordKeysOverlap (Record r1) (Record r2)

class RowKeysOverlap (r1 :: Row Type) (r2 :: Row Type)

instance
  (RowToList r1 rl1
  , RowListKeysOverlap rl1 r2
  ) =>
  RowKeysOverlap r1 r2

class RowListKeysOverlap (rl1 :: RowList Type) (r2 :: Row Type)

instance RowListKeysOverlap Nil r2

instance
  (Row.Cons key val2 tail2 r2
  , RowListKeysOverlap tail r2
  ) =>
  RowListKeysOverlap (Cons key val tail) r2

class ExtractRowKeys (row :: Row Type) where
  extractRowKeys :: Array String

instance (RowToList row rl, ExtractRowListKeys rl) => ExtractRowKeys row where
  extractRowKeys = extractRowListKeys @rl

class ExtractRowListKeys (rl :: RowList Type) where
  extractRowListKeys :: Array String

instance ExtractRowListKeys Nil where
  extractRowListKeys = []

instance (IsSymbol key, ExtractRowListKeys tail) => ExtractRowListKeys (Cons key value tail) where
  extractRowListKeys = [ ᴠ @key ] <> extractRowListKeys @tail

class InRowList (a :: Type) (rl :: RowList Type)

instance InRowList a (Cons sym a tail)
else instance InRowList a tail => InRowList a (Cons sym b tail)

class InRow (a :: Type) (r :: Row Type)

instance (RowToList r rl, InRowList a rl) => InRow a r
