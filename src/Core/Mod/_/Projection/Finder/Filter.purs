module Core.Mod.Projection.Finder.Filter
  ( Contains(..)
  , EqualsUpToNormalization(..)
  , Filter(..)
  , Exists(..)
  , GreaterThan(..)
  , InnerWeightA
  , InnerWeightB
  , InnerWeightC
  , InnerWeightD
  , LessThan(..)
  , module Util.Type.Limit
  , Matches(..)
  , Op(..)
  , Path_
  , StrictlyEquals(..)
  , StrictlyNotEquals(..)
  , Type_
  , Value_
  , Weight
  , by
  , byExists
  , false_
  , true_
  , byKey
  , byMatches
  , byType
  , class IsFilter
  , class IsOp
  , class IsValidOp
  , class OpRequiresIndex
  , compile
  , defaultInnerWeightA
  , defaultInnerWeightB
  , defaultInnerWeightC
  , defaultInnerWeightD
  , defaultLimit
  , defaultLimit_
  , fold
  , noFilter
  , noLimit
  , toOp
  ) where

import Proem

import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation)
import Core.Mod.Projection.Pair (Key, class IsPair, persistenceKeyFromKey)
import Core.Mod.Projection.SearchIndex (IndexNeeds, Yes, YesWithWeightA, YesWithWeightB, YesWithWeightC, YesWithWeightD)
import Core.Mod.Time.Instant as Time
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Data.String as String
import Data.Symbol (class IsSymbol)
import Foreign (Foreign)
import Foreign as Foreign
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Limit (Limit(..))
import Util.Type.Row.HasNestedKey (class HasNestedKey)
import Yoga.JSON (class ReadForeign, class WriteForeign, writeImpl)

type Type_ = String
type Path_ = Array String
type Value_ = Foreign

type Weight = Number

type InnerWeightA = Weight
type InnerWeightB = Weight
type InnerWeightC = Weight
type InnerWeightD = Weight

defaultInnerWeightA :: InnerWeightA
defaultInnerWeightA = 1.0

defaultInnerWeightB :: InnerWeightB
defaultInnerWeightB = 0.7

defaultInnerWeightC :: InnerWeightC
defaultInnerWeightC = 0.4

defaultInnerWeightD :: InnerWeightD
defaultInnerWeightD = 0.1

noFilter :: ∀ a. Maybe a
noFilter = Nothing

data Op
  = StrictlyEquals_
  | StrictlyNotEquals_
  | Exists_
  | EqualsUpToNormalization_
  | Matches_ { weight :: Weight, expectation :: Expectation }
  | Contains_
  | GreaterThan_
  | LessThan_

derive instance Eq Op
derive instance Ord Op
derive instance Generic Op _

instance WriteForeign Op where
  writeImpl = genericWriteImplWithDefaultOpt

instance ReadForeign Op where
  readImpl = genericReadImplWithDefaultOpt

instance Show Op where
  show = genericShow

data StrictlyEquals = StrictlyEquals
data StrictlyNotEquals = StrictlyNotEquals
data Exists = Exists
data EqualsUpToNormalization = EqualsUpToNormalization
data Matches = Matches { weight :: Weight, expectation :: Expectation }
data Contains = Contains
data GreaterThan = GreaterThan
data LessThan = LessThan

class IsOp op where
  toOp :: op -> Op

instance IsOp StrictlyEquals where
  toOp _ = StrictlyEquals_

instance IsOp StrictlyNotEquals where
  toOp _ = StrictlyNotEquals_

instance IsOp Exists where
  toOp _ = Exists_

instance IsOp EqualsUpToNormalization where
  toOp _ = EqualsUpToNormalization_

instance IsOp Matches where
  toOp (Matches r) = Matches_ r

instance IsOp Contains where
  toOp _ = Contains_

instance IsOp GreaterThan where
  toOp _ = GreaterThan_

instance IsOp LessThan where
  toOp _ = LessThan_

class IsOp op <= IsValidOp (op :: Type) (fieldValue :: Type)

instance IsValidOp StrictlyEquals val
instance IsValidOp StrictlyNotEquals val
instance IsValidOp Exists val

instance IsValidOp EqualsUpToNormalization String
instance IsValidOp EqualsUpToNormalization a => IsValidOp EqualsUpToNormalization (Maybe a)

instance IsValidOp Matches String
instance IsValidOp Matches a => IsValidOp Matches (Maybe a)
instance IsValidOp Matches a => IsValidOp Matches (Array a)

instance IsValidOp Contains (Array a)

instance IsValidOp GreaterThan Int
instance IsValidOp LessThan Int
instance IsValidOp GreaterThan Number
instance IsValidOp LessThan Number
instance IsValidOp GreaterThan Time.Instant
instance IsValidOp LessThan Time.Instant

class OpRequiresIndex (op :: Type) (r :: Type) (n :: Type) (f :: Type) (i :: Type)

instance OpRequiresIndex StrictlyEquals Yes n f i
instance OpRequiresIndex StrictlyNotEquals Yes n f i
instance OpRequiresIndex Exists Yes n f i
instance OpRequiresIndex EqualsUpToNormalization r Yes f i
instance OpRequiresIndex Matches r n YesWithWeightA i
instance OpRequiresIndex Matches r n YesWithWeightB i
instance OpRequiresIndex Matches r n YesWithWeightC i
instance OpRequiresIndex Matches r n YesWithWeightD i
instance OpRequiresIndex Contains r n f Yes
instance OpRequiresIndex GreaterThan Yes n f i
instance OpRequiresIndex LessThan Yes n f i

-- | Foreign acts here as a closed "Any", universal primitive type for data transport.
-- | This does not enforce a serialization format.
-- | This is simply in line with the representability required of objects in the domain (writeImpl/readImpl).
data Filter (value :: Type)
  = ByKey Key
  | ByType Type_
  | ByValuePair Path_ Op Value_
  | ByValueMatches Weight { a :: InnerWeightA, b :: InnerWeightB, c :: InnerWeightC, d :: InnerWeightD, e :: Expectation, val :: String }
  | And (Filter value) (Filter value)
  | Or (Filter value) (Filter value)
  | Not (Filter value)
  | True
  | False

class IsFilter filter value | filter -> value where
  compile :: Expectation -> filter -> Filter value

instance HeytingAlgebra (Filter value) where
  ff = False
  tt = True
  not = Not
  implies a b = Or (Not a) b
  conj = And
  disj = Or

noLimit :: ∀ a. Limit a
noLimit = Infinite

defaultLimit_ :: Int
defaultLimit_ = 12

defaultLimit :: Limit Int
defaultLimit = Finite defaultLimit_

by
  :: ∀ @field @value op singularName fieldValue valueRecord indexes r n f i
   . IsPair _ value valueRecord indexes _ singularName _ _ _
  => Newtype value valueRecord
  => HasNestedKey valueRecord field fieldValue
  => HasNestedKey indexes field (IndexNeeds r n f i fieldValue)
  => IsSymbol singularName
  => IsSymbol field
  => WriteForeign fieldValue
  => ReadForeign value
  => IsValidOp op fieldValue
  => OpRequiresIndex op r n f i
  => op
  -> fieldValue
  -> Filter value
by op val =
  And (byType @value)
    (ByValuePair (String.split (String.Pattern ".") (ᴠ @field)) (toOp op) (val # writeImpl))

byExists
  :: ∀ @field @value singularName fieldValue valueRecord indexes r n f i
   . IsPair _ value valueRecord indexes _ singularName _ _ _
  => Newtype value valueRecord
  => HasNestedKey valueRecord field fieldValue
  => HasNestedKey indexes field (IndexNeeds r n f i fieldValue)
  => IsSymbol singularName
  => IsSymbol field
  => Filter value
byExists =
  And (byType @value)
    (ByValuePair (String.split (String.Pattern ".") (ᴠ @field)) Exists_ (Foreign.unsafeToForeign false))

byMatches
  :: ∀ @value singularName
   . IsPair _ value _ _ _ singularName _ _ _
  => IsSymbol singularName
  => Weight
  -> InnerWeightA
  -> InnerWeightB
  -> InnerWeightC
  -> InnerWeightD
  -> Expectation
  -> String
  -> Filter value
byMatches w a b c d e val =
  And (byType @value)
    (ByValueMatches w { a, b, c, d, e, val })

byKey
  :: ∀ key value singularName pluralName
   . IsPair key value _ _ _ singularName pluralName _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => ReadForeign value
  => key
  -> Filter value
byKey key = ByKey $ persistenceKeyFromKey key

byType
  :: ∀ @value singularName
   . IsPair _ value _ _ _ singularName _ _ _
  => IsSymbol singularName
  => Filter value
byType = ByType $ ᴠ @singularName

-- | Equivalent to WHERE true in SQL.
true_ :: ∀ value. Filter value
true_ = True

-- | Equivalent to WHERE false in SQL.
false_ :: ∀ value. Filter value
false_ = False

fold
  :: ∀ a value
   . (Key -> a)
  -> (Type_ -> a)
  -> (Path_ -> Op -> Value_ -> a)
  -> (Weight -> InnerWeightA -> InnerWeightB -> InnerWeightC -> InnerWeightD -> Expectation -> String -> a)
  -> (Unit -> a)
  -> (Unit -> a)
  -> (a -> a -> a)
  -> (a -> a -> a)
  -> (a -> a)
  -> Filter value
  -> a
fold onByKey onByType onByValuePair onByValueMatches onTrue onFalse onAnd onOr onNot filter = case filter of
  ByKey key -> onByKey key
  ByType type_ -> onByType type_
  ByValuePair path op value -> onByValuePair path op value
  ByValueMatches w r -> onByValueMatches w r.a r.b r.c r.d r.e r.val
  True -> onTrue unit
  False -> onFalse unit
  And f1 f2 ->
    let
      x = fold onByKey onByType onByValuePair onByValueMatches onTrue onFalse onAnd onOr onNot f1
      y = fold onByKey onByType onByValuePair onByValueMatches onTrue onFalse onAnd onOr onNot f2
    in
      onAnd x y
  Or f1 f2 ->
    let
      x = fold onByKey onByType onByValuePair onByValueMatches onTrue onFalse onAnd onOr onNot f1
      y = fold onByKey onByType onByValuePair onByValueMatches onTrue onFalse onAnd onOr onNot f2
    in
      onOr x y
  Not f1 ->
    let
      x = fold onByKey onByType onByValuePair onByValueMatches onTrue onFalse onAnd onOr onNot f1
    in
      onNot x

mapExpectation :: ∀ value. (Expectation -> Expectation) -> Filter value -> Filter value
mapExpectation f filter = case filter of
  ByValuePair path (Matches_ r) value -> ByValuePair path (Matches_ r { expectation = f r.expectation }) value
  ByValueMatches w r -> ByValueMatches w r { e = f r.e }
  And f1 f2 -> And (mapExpectation f f1) (mapExpectation f f2)
  Or f1 f2 -> Or (mapExpectation f f1) (mapExpectation f f2)
  Not f1 -> Not (mapExpectation f f1)
  _ -> filter

instance IsFilter (Filter value) value where
  compile _ filter = filter

