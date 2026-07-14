module Core.Mod.Projection.Projection
  (ProjectionWriteOps(..)
  , add
  , noAfter
  , class IsProjection
  , coerce
  , delete
  , get
  , indexNeeds
  , indexPaths
  , patch
  , play
  , put
  ) where

import Proem
import Control.Monad.Except (runExcept)

import Core.Event.Event (LoadedEvent)
import Core.Mod.Projection.Pair (class IsPair, Key, persistenceKeyFromKey, persistenceKeyFromValue)
import Core.Mod.Projection.SearchIndex (class ExtractIndexPaths, class ValidateIndexNeeds, class ValidateSortRows, IndexPaths, extractIndexPaths)
import Foreign (Foreign)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Array as Array
import Data.Either (Either(..), hush)
import Data.Maybe (Maybe(..))
import Data.Set as Set
import Data.Symbol (class IsSymbol)
import Prim.Row as Row
import Run (Run, lift)
import Safe.Coerce as Safe

-- | Foreign acts here as a closed "Any", universal primitive type for data transport.
-- | This does not enforce a serialization format.
-- | This is simply in line with the representability required of objects in the domain (writeImpl/readImpl).
data ProjectionWriteOps a
  = Add Key Foreign a
  | Get Key (Maybe Foreign -> a)
  | Put Key Foreign a
  | Patch Key (Foreign -> Foreign) a
  | Delete Key a

derive instance Functor ProjectionWriteOps

-- | After nothing.
noAfter :: ∀ a. Maybe a
noAfter = Nothing

class
  (ExtractIndexPaths centralValueIndexNeeds
  , ValidateIndexNeeds centralValueIndexNeeds centralValues
  , ValidateSortRows centralValueSortRows centralValueIndexNeeds
  ) <=
  IsProjection
    (proj :: Type)
    (name :: Symbol)
    (opsEffSym :: Symbol)
    (opsEff :: Row (Type -> Type))
    (syncEffSym :: Symbol)
    (centralValues :: Type)
    (centralValueIndexNeeds :: Type)
    (centralValueSortRows :: Type)
  | proj -> name
  , proj -> opsEffSym
  , proj -> opsEff
  , proj -> syncEffSym
  , proj -> centralValues
  , proj -> centralValueIndexNeeds
  , proj -> centralValueSortRows
  where
  indexNeeds :: centralValueIndexNeeds

  play
    :: ∀ fx_ fx
     . Row.Union opsEff fx_ fx
    => LoadedEvent
    -> Run fx Ɩ

add
  :: ∀ singularName pluralName value p opsEffSym fx
   . IsPair _ value _ _ _ singularName pluralName _ p
  => IsProjection p _ opsEffSym _ _ _ _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol opsEffSym
  => WriteForeign value
  => Row.Cons opsEffSym ProjectionWriteOps _ fx
  => value
  -> Run fx Ɩ
add v = lift (π :: Π opsEffSym) $
  Add (persistenceKeyFromValue v) (writeImpl v) ι

get
  :: ∀ singularName pluralName key value p opsEffSym fx
   . IsPair key value _ _ _ singularName pluralName _ p
  => IsProjection p _ opsEffSym _ _ _ _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol opsEffSym
  => ReadForeign value
  => Row.Cons opsEffSym ProjectionWriteOps _ fx
  => key
  -> Run fx (Maybe value)
get k = lift (π :: Π opsEffSym) $
  Get (persistenceKeyFromKey k) \m -> do
    json <- m
    runExcept (readImpl json) # hush

put
  :: ∀ singularName pluralName value p opsEffSym fx
   . IsPair _ value _ _ _ singularName pluralName _ p
  => IsProjection p _ opsEffSym _ _ _ _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol opsEffSym
  => WriteForeign value
  => Row.Cons opsEffSym ProjectionWriteOps _ fx
  => value
  -> Run fx Ɩ
put v = lift (π :: Π opsEffSym) $
  Put (persistenceKeyFromValue v) (writeImpl v) ι

patch
  :: ∀ singularName pluralName key value p opsEffSym fx
   . IsPair key value _ _ _ singularName pluralName _ p
  => IsProjection p _ opsEffSym _ _ _ _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol opsEffSym
  => WriteForeign value
  => ReadForeign value
  => Row.Cons opsEffSym ProjectionWriteOps _ fx
  => key
  -> (value -> value)
  -> Run fx Ɩ
patch k f = lift (π :: Π opsEffSym) $
  Patch (persistenceKeyFromKey k) patch_ ι
  where
  patch_ :: Foreign -> Foreign
  patch_ json =
    case runExcept (readImpl @value json) of
      Right val -> writeImpl $ f val
      Left _ -> json

delete
  :: ∀ singularName pluralName key value p opsEffSym fx
   . IsPair key value _ _ _ singularName pluralName _ p
  => IsProjection p _ opsEffSym _ _ _ _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => IsSymbol opsEffSym
  => Row.Cons opsEffSym ProjectionWriteOps _ fx
  => key
  -> Run fx Ɩ
delete k = lift (π :: Π opsEffSym) $
  Delete (persistenceKeyFromKey k) ι

coerce
  :: ∀ @opsEff fx
   . (LoadedEvent -> Run opsEff Ɩ)
  -> (LoadedEvent -> Run fx Ɩ)
coerce = Safe.coerce

indexPaths
  :: ∀ @p centralValueIndexNeeds
   . IsProjection p _ _ _ _ _ centralValueIndexNeeds _
  => String
  -> IndexPaths
indexPaths singularType =
  let
    res = extractIndexPaths [] (indexNeeds @p)
    strip arr = case Array.uncons arr of
      Just { head, tail } | head == singularType -> Just tail
      _ -> Nothing
  in
    { raw: Array.fromFoldable $ Set.fromFoldable (Array.mapMaybe strip res.raw)
    , normalized: Array.fromFoldable $ Set.fromFoldable (Array.mapMaybe strip res.normalized)
    , fullTextA: Array.fromFoldable $ Set.fromFoldable (Array.mapMaybe strip res.fullTextA)
    , fullTextB: Array.fromFoldable $ Set.fromFoldable (Array.mapMaybe strip res.fullTextB)
    , fullTextC: Array.fromFoldable $ Set.fromFoldable (Array.mapMaybe strip res.fullTextC)
    , fullTextD: Array.fromFoldable $ Set.fromFoldable (Array.mapMaybe strip res.fullTextD)
    , inverted: Array.fromFoldable $ Set.fromFoldable (Array.mapMaybe strip res.inverted)
    }
