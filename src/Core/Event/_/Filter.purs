module Core.Event.Filter
  ( Filter(..)
  , Path
  , Type_
  , Value
  , by
  , false_
  , true_
  , byType
  , fold
  ) where

import Proem

import Core.Event.Event (class IsEvent)
import Util.Type.Type (reflectName)
import Util.Type.Row.HasNestedKey (class HasNestedKey)
import Foreign (Foreign)
import Yoga.JSON (class WriteForeign, writeImpl)
import Data.Symbol (class IsSymbol)

import Data.String as String

type Type_ = String
type Path = Array String
type Value = Foreign

-- | Foreign acts here as a closed "Any", universal primitive type for data transport.
-- | This does not enforce a serialization format.
-- | This is simply in line with the representability required of objects in the domain (writeImpl/readImpl).
data Filter
  = ByType Type_
  | ByPayloadPair Path Value
  | True -- Equivalent to WHERE true in SQL
  | False -- Equivalent to WHERE false in SQL
  | And Filter Filter
  | Or Filter Filter
  | Not Filter


instance HeytingAlgebra Filter where
  ff = False
  tt = True
  not = Not
  implies a b = Or (Not a) b
  conj = And
  disj = Or

by
  :: ∀ @event @path payload value
   . IsEvent event payload
  => HasNestedKey payload path value
  => IsSymbol path
  => WriteForeign value
  => value
  -> Filter
by value =
  And (byType @event)
    (ByPayloadPair (String.split (String.Pattern ".") (ᴠ @path)) (value # writeImpl))

byType :: ∀ @event payload. IsEvent event payload => Filter
byType = ByType $ reflectName @event

-- | Equivalent to WHERE true in SQL.
true_ :: Filter
true_ = True

-- | Equivalent to WHERE false in SQL.
false_ :: Filter
false_ = False

fold
  :: ∀ a
   . (Type_ -> a)
  -> (Path -> Value -> a)
  -> a
  -> a
  -> (a -> a -> a)
  -> (a -> a -> a)
  -> (a -> a)
  -> Filter
  -> a
fold onByType onByPayloadPair onTrue onFalse onAnd onOr onNot filter = case filter of
  ByType type_ -> onByType type_
  ByPayloadPair path value -> onByPayloadPair path value
  True -> onTrue
  False -> onFalse
  And f1 f2 ->
    let
      x = fold onByType onByPayloadPair onTrue onFalse onAnd onOr onNot f1
      y = fold onByType onByPayloadPair onTrue onFalse onAnd onOr onNot f2
    in
      onAnd x y
  Or f1 f2 ->
    let
      x = fold onByType onByPayloadPair onTrue onFalse onAnd onOr onNot f1
      y = fold onByType onByPayloadPair onTrue onFalse onAnd onOr onNot f2
    in
      onOr x y
  Not f1 ->
    let
      x = fold onByType onByPayloadPair onTrue onFalse onAnd onOr onNot f1
    in
      onNot x
