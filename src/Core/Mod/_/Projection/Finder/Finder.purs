module Core.Mod.Projection.Finder.Finder where

import Proem hiding ((&&), (||))

import Core.Mod.Projection.Finder.Filter (class IsFilter, class IsValidOp, class OpRequiresIndex, Filter(..), Limit(..), by, byKey, compile)
import Core.Mod.Projection.Finder.Sort (SortCriteria, noSort)
import Core.Mod.Projection.Pair (class IsPair, Key, persistenceKeyFromKey)
import Core.Mod.Projection.Projection (class IsProjection)
import Core.Mod.Projection.SearchIndex (IndexNeeds)
import Core.Mod.Projection.SyncProject (SyncProject, syncProject)
import Core.Mod.Projection.Finder.Expectation.Expectation (Expectation(..))
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Array (head, uncons)
import Data.Foldable (foldl)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Symbol (class IsSymbol)
import Prim.Row as Row
import Run (Run, lift)
import Util.Type.Row.HasNestedKey (class HasNestedKey)

type Page value =
  { items :: Array value
  , hasNextPage :: Boolean
  }

type FindOpt filter after value =
  { filter :: Maybe filter
  , limit :: Limit Int
  , expectation :: Expectation
  , after :: Maybe after
  , sort :: SortCriteria value
  }

defaultFindOpt :: ∀ filter after value. FindOpt filter after value
defaultFindOpt =
  { filter: Nothing
  , limit: Finite 16
  , expectation: SlowerSomethingBetterThanQuickNothing
  , after: Nothing
  , sort: noSort
  }

data Find value a
  = FindMany (Array (FindOpt (Filter value) Key value)) (Array (Page value) -> a)
  | GetReadModelHash (Maybe Key) (String -> a)

derive instance Functor (Find value)

parFindMany_
  :: ∀ singularName findEffSym syncEffSym value p centralValueRow fx filter
   . IsFilter filter value
  => IsPair _ value _ _ _ singularName _ findEffSym p
  => IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => Array (FindOpt filter Key value)
  -> Run fx (Array (Page value))
parFindMany_ queries = do
  syncProject @p

  let compiledOpts = queries <#> \opt -> opt { filter = compile opt.expectation <$> opt.filter }

  lift (π :: Π findEffSym) (FindMany compiledOpts identity)

findMany_
  :: ∀ singularName findEffSym syncEffSym value p centralValueRow fx filter
   . IsFilter filter value
  => IsPair _ value _ _ _ singularName _ findEffSym p
  => IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => FindOpt filter Key value
  -> Run fx (Page value)
findMany_ opt = do
  pages <- parFindMany_ [ opt ]
  case uncons pages of
    Just { head } -> η head
    Nothing -> η { items: [], hasNextPage: false }

parFindMany
  :: ∀ singularName findEffSym syncEffSym filter value p centralValueRow fx
   . IsPair _ value _ _ _ singularName _ findEffSym p
  => IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => IsFilter filter value
  => Array (FindOpt filter Key value)
  -> Run fx (Array (Array value))
parFindMany queries = do
  pages <- parFindMany_ queries
  η (pages <#> _.items)

findMany
  :: ∀ singularName findEffSym syncEffSym filter value p centralValueRow fx
   . IsPair _ value _ _ _ singularName _ findEffSym p
  => IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => IsFilter filter value
  => FindOpt filter Key value
  -> Run fx (Array value)
findMany opt = findMany_ opt >>= (η ◁ _.items)

findAll
  :: ∀ singularName findEffSym syncEffSym value p centralValueRow fx
   . IsPair _ value _ _ _ singularName _ findEffSym p
  => IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => Run fx (Array value)
findAll = findMany_ (defaultFindOpt :: FindOpt (Filter value) Key value) >>= (η ◁ _.items)

findManyBy
  :: ∀ @value @field p singularName op fieldValue valueRecord indexes findEffSym syncEffSym centralValueRow fx (r :: Type) (n :: Type) (f :: Type) (i :: Type)
   . IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => IsPair _ value valueRecord indexes _ singularName _ findEffSym p
  => Row.Cons singularName value _ centralValueRow
  => Newtype value valueRecord
  => HasNestedKey valueRecord field fieldValue
  => HasNestedKey indexes field (IndexNeeds r n f i fieldValue)
  => IsSymbol singularName
  => IsSymbol field
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => WriteForeign fieldValue
  => IsValidOp op fieldValue
  => OpRequiresIndex op r n f i
  => op
  -> fieldValue
  -> Limit Int
  -> Maybe Key
  -> Run fx (Array value)
findManyBy op val limit after = findMany_ (defaultFindOpt { limit = limit, after = after, filter = Just $ by @field @value op val }) >>= (η ◁ _.items)

findOne
  :: ∀ p syncEffSym value singularName findEffSym centralValueRow fx filter
   . IsFilter filter value
  => IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => IsPair _ value _ _ _ singularName _ findEffSym p
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => ReadForeign value
  => filter
  -> Run fx (Maybe value)
findOne filter = findMany_ (defaultFindOpt { limit = Finite 1, filter = Just filter }) >>= (η ◁ head ◁ _.items)

findOneBy
  :: ∀ @value @field p syncEffSym singularName op fieldValue valueRecord indexes findEffSym centralValueRow fx (r :: Type) (n :: Type) (f :: Type) (i :: Type)
   . IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => IsPair _ value valueRecord indexes _ singularName _ findEffSym p
  => Row.Cons singularName value _ centralValueRow
  => Newtype value valueRecord
  => HasNestedKey valueRecord field fieldValue
  => HasNestedKey indexes field (IndexNeeds r n f i fieldValue)
  => IsSymbol singularName
  => IsSymbol field
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => WriteForeign fieldValue
  => IsValidOp op fieldValue
  => OpRequiresIndex op r n f i
  => op
  -> fieldValue
  -> Run fx (Maybe value)
findOneBy op val = findOne $ by @field @value op val

findOneByKey
  :: ∀ p syncEffSym key value singularName pluralName findEffSym centralValueRow fx
   . IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => IsPair key value _ _ _ singularName pluralName findEffSym p
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => ReadForeign value
  => key
  -> Run fx (Maybe value)
findOneByKey key = findOne $ byKey key

findManyByKeys
  :: ∀ p syncEffSym key value singularName pluralName findEffSym centralValueRow fx
   . IsProjection p _ _ _ syncEffSym (Record centralValueRow) _ _
  => IsPair key value _ _ _ singularName pluralName findEffSym p
  => Row.Cons singularName value _ centralValueRow
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol findEffSym
  => IsSymbol syncEffSym
  => Row.Cons findEffSym (Find value) _ fx
  => Row.Cons syncEffSym SyncProject _ fx
  => ReadForeign value
  => Array key
  -> Run fx (Array value)
findManyByKeys keys = case uncons keys of
  Nothing -> η []
  Just { head: h, tail: t } -> do
    page <- findMany_ (defaultFindOpt { filter = Just $ foldl (\acc k -> Or acc (byKey k)) (byKey h) t })
    η page.items

getReadModelHash
  :: ∀ @v p singularName pluralName key findEffSym fx
   . IsPair key v _ _ _ singularName pluralName findEffSym p
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol findEffSym
  => Row.Cons findEffSym (Find v) _ fx
  => Maybe key
  -> Run fx String
getReadModelHash mKey = lift (π :: Π findEffSym) (GetReadModelHash (persistenceKeyFromKey <$> mKey) identity)
