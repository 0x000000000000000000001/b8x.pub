module Core.Mod.Projection.SearchIndex where

import Proem

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Symbol (class IsSymbol)
import Prim.Row as Row
import Prim.RowList (class RowToList, Cons, Nil, RowList)
import Record as Record
import Type.Proxy (Proxy(..))
import Util.Type.Record (class UnwrapRecord)
import Util.Type.Row.Row (class RecordKeysMatch, class RecordKeysOverlap)
import Util.Type.Row.HasNestedKey (class HasNestedKeys)

type Path = Array String

type IndexPaths =
  { raw :: Array Path
  , normalized :: Array Path
  , fullTextA :: Array Path
  , fullTextB :: Array Path
  , fullTextC :: Array Path
  , fullTextD :: Array Path
  , inverted :: Array Path
  }

data Yes
data No

data YesWithWeightA
data YesWithWeightB
data YesWithWeightC
data YesWithWeightD

data FtsWeight = A | B | C | D

derive instance Eq FtsWeight

type RawIndexOnly a = IndexNeeds Yes No No No a
type InvertedIndexOnly a = IndexNeeds No No No Yes a

type EveryTextIndexesWithWeightA a = IndexNeeds Yes Yes YesWithWeightA No a
type EveryTextIndexesWithWeightB a = IndexNeeds Yes Yes YesWithWeightB No a
type EveryTextIndexesWithWeightC a = IndexNeeds Yes Yes YesWithWeightC No a
type EveryTextIndexesWithWeightD a = IndexNeeds Yes Yes YesWithWeightD No a

type FullTextIndexOnlyA a = IndexNeeds No No YesWithWeightA No a
type FullTextIndexOnlyB a = IndexNeeds No No YesWithWeightB No a
type FullTextIndexOnlyC a = IndexNeeds No No YesWithWeightC No a
type FullTextIndexOnlyD a = IndexNeeds No No YesWithWeightD No a

newtype IndexNeeds
  (r :: Type) -- raw
  (n :: Type) -- normalized
  (f :: Type) -- full text search
  (i :: Type) -- inverted
  (a :: Type) =
  IndexNeeds
    { raw :: Boolean
    , normalized :: Boolean
    , fullText :: Maybe FtsWeight
    , inverted :: Boolean
    }

class IsScalar (a :: Type)

instance IsScalar String
instance IsScalar Boolean
instance IsScalar Int
instance IsScalar a => IsScalar (Maybe a)
instance IsScalar (Array a)

class (IsScalar a) <= IsText (a :: Type)

class IsInverted (a :: Type)

instance IsText String
instance IsText a => IsText (Maybe a)
instance IsText a => IsText (Array a)

instance IsInverted (Array a)

rawIndexOnly :: ∀ a. IsScalar a => RawIndexOnly a
rawIndexOnly = IndexNeeds
  { raw: true
  , normalized: false
  , fullText: Nothing
  , inverted: false
  }

invertedIndexOnly :: ∀ a. IsInverted a => InvertedIndexOnly a
invertedIndexOnly = IndexNeeds
  { raw: false
  , normalized: false
  , fullText: Nothing
  , inverted: true
  }

everyTextIndexesWithWeightA :: ∀ a. IsText a => EveryTextIndexesWithWeightA a
everyTextIndexesWithWeightA = IndexNeeds
  { raw: true
  , normalized: true
  , fullText: Just A
  , inverted: false
  }

everyTextIndexesWithWeightB :: ∀ a. IsText a => EveryTextIndexesWithWeightB a
everyTextIndexesWithWeightB = IndexNeeds
  { raw: true
  , normalized: true
  , fullText: Just B
  , inverted: false
  }

everyTextIndexesWithWeightC :: ∀ a. IsText a => EveryTextIndexesWithWeightC a
everyTextIndexesWithWeightC = IndexNeeds
  { raw: true
  , normalized: true
  , fullText: Just C
  , inverted: false
  }

everyTextIndexesWithWeightD :: ∀ a. IsText a => EveryTextIndexesWithWeightD a
everyTextIndexesWithWeightD = IndexNeeds
  { raw: true
  , normalized: true
  , fullText: Just D
  , inverted: false
  }

fullTextIndexOnlyWithWeightA :: ∀ a. IsText a => FullTextIndexOnlyA a
fullTextIndexOnlyWithWeightA = IndexNeeds
  { raw: false
  , normalized: false
  , fullText: Just A
  , inverted: false
  }

fullTextIndexOnlyWithWeightB :: ∀ a. IsText a => FullTextIndexOnlyB a
fullTextIndexOnlyWithWeightB = IndexNeeds
  { raw: false
  , normalized: false
  , fullText: Just B
  , inverted: false
  }

fullTextIndexOnlyWithWeightC :: ∀ a. IsText a => FullTextIndexOnlyC a
fullTextIndexOnlyWithWeightC = IndexNeeds
  { raw: false
  , normalized: false
  , fullText: Just C
  , inverted: false
  }

fullTextIndexOnlyWithWeightD :: ∀ a. IsText a => FullTextIndexOnlyD a
fullTextIndexOnlyWithWeightD = IndexNeeds
  { raw: false
  , normalized: false
  , fullText: Just D
  , inverted: false
  }

class ExtractIndexPaths a where
  extractIndexPaths :: Path -> a -> IndexPaths

instance ExtractIndexPaths (IndexNeeds r n fts i a) where
  extractIndexPaths prefix (IndexNeeds needs) =
    { raw: needs.raw ? [ prefix ] ↔ []
    , normalized: needs.normalized ? [ prefix ] ↔ []
    , fullTextA: needs.fullText == Just A ? [ prefix ] ↔ []
    , fullTextB: needs.fullText == Just B ? [ prefix ] ↔ []
    , fullTextC: needs.fullText == Just C ? [ prefix ] ↔ []
    , fullTextD: needs.fullText == Just D ? [ prefix ] ↔ []
    , inverted: needs.inverted ? [ prefix ] ↔ []
    }

instance
  (RowToList row rl
  , ExtractIndexPathsInRowList rl row
  ) =>
  ExtractIndexPaths (Record row) where
  extractIndexPaths prefix rec =
    extractIndexPathsInRowList @rl prefix rec

class ExtractIndexPathsInRowList (rl :: RowList Type) (row :: Row Type) | rl -> row where
  extractIndexPathsInRowList :: Path -> Record row -> IndexPaths

instance ExtractIndexPathsInRowList Nil row where
  extractIndexPathsInRowList _ _ =
    { raw: []
    , normalized: []
    , fullTextA: []
    , fullTextB: []
    , fullTextC: []
    , fullTextD: []
    , inverted: []
    }

instance
  (IsSymbol sym
  , Row.Cons sym ty tailRow row
  , ExtractIndexPaths ty
  , ExtractIndexPathsInRowList tail row
  ) =>
  ExtractIndexPathsInRowList (Cons sym ty tail) row where
  extractIndexPathsInRowList prefix rec =
    let
      sym = ᴠ @sym
      newPrefix = Array.snoc prefix sym
      val = Record.get (Proxy @sym) rec
      headRes = extractIndexPaths newPrefix val
      tailRes = extractIndexPathsInRowList @tail prefix rec
    in
      { raw: headRes.raw <> tailRes.raw
      , normalized: headRes.normalized <> tailRes.normalized
      , fullTextA: headRes.fullTextA <> tailRes.fullTextA
      , fullTextB: headRes.fullTextB <> tailRes.fullTextB
      , fullTextC: headRes.fullTextC <> tailRes.fullTextC
      , fullTextD: headRes.fullTextD <> tailRes.fullTextD
      , inverted: headRes.inverted <> tailRes.inverted
      }

class ValidateIndexNeeds (needs :: Type) (centralValues :: Type)

instance
  (RecordKeysMatch (Record needsRow) (Record centralValuesRow)
  , RowToList needsRow needsRowList
  , ValidateIndexNeedsRL needsRowList centralValuesRow
  ) =>
  ValidateIndexNeeds (Record needsRow) (Record centralValuesRow)

class ValidateIndexNeedsRL (needsRowList :: RowList Type) (centralValues :: Row Type)

instance ValidateIndexNeedsRL Nil centralValues

instance
  (Row.Cons key centralValue whatever centralValues
  , UnwrapRecord centralValue centralValueRow
  , ValidateIndexNeeds_ needRow centralValueRow
  , ValidateIndexNeedsRL tail centralValues
  ) =>
  ValidateIndexNeedsRL (Cons key (Record needRow) tail) centralValues

class ValidateIndexNeeds_ (needs :: Row Type) (centralValueTypes :: Row Type)

instance
  (RecordKeysOverlap (Record needs) (Record centralValueTypes)
  , RowToList needs needsRowList
  , ValidateIndexNeedsRL_ needsRowList centralValueTypes
  ) =>
  ValidateIndexNeeds_ needs centralValueTypes

class ValidateIndexNeedsRL_ (needsRowList :: RowList Type) (centralValueTypes :: Row Type)

instance ValidateIndexNeedsRL_ Nil centralValueTypes

instance
  (Row.Cons key centralValueType whatever centralValueTypes
  , ValidateIndexNeedsRL_ tail centralValueTypes
  ) =>
  ValidateIndexNeedsRL_ (Cons key (IndexNeeds r n f i centralValueType) tail) centralValueTypes

instance
  (Row.Cons key centralValueType whatever centralValueTypes
  , UnwrapRecord centralValueType centralValueRow
  , ValidateIndexNeeds_ needRow centralValueRow
  , ValidateIndexNeedsRL_ tail centralValueTypes
  ) =>
  ValidateIndexNeedsRL_ (Cons key (Record needRow) tail) centralValueTypes

class ValidateSortRows (sortRows :: Type) (indexNeeds :: Type)

instance
  (RecordKeysMatch (Record sortRowsR) (Record indexNeedsR)
  , RowToList sortRowsR sortRowsList
  , ValidateSortRowsRL sortRowsList indexNeedsR
  ) =>
  ValidateSortRows (Record sortRowsR) (Record indexNeedsR)

class ValidateSortRowsRL (sortRowsList :: RowList Type) (indexNeeds :: Row Type)

instance ValidateSortRowsRL Nil indexNeeds

instance
  (Row.Cons key sortRowIndexNeeds whatever indexNeeds
  , HasNestedKeys sortRow sortRowIndexNeeds
  , ValidateSortRowsRL tail indexNeeds
  ) =>
  ValidateSortRowsRL (Cons key (Record sortRow) tail) indexNeeds
