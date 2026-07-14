module Core.Mod.Projection.Pair where

import Proem

import Core.Mod.Projection.SearchIndex (class ExtractIndexPaths)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Symbol (class IsSymbol)
import Util.Type.Row.Row (class RecordKeysOverlap)

type Key_ =
  { primary :: String
  , aliases :: Array String
  }

class ToAliasedPrimary a where
  toAliasedPrimary :: a -> Key_

newtype Key = Key
  { singularType :: String
  , pluralType :: String
  , primary :: Maybe String
  , aliases :: Array String
  }

derive instance Eq Key
derive instance Ord Key
derive instance Newtype Key _
derive newtype instance Show Key
derive newtype instance WriteForeign Key
derive newtype instance ReadForeign Key

class
  ( ToAliasedPrimary key
  , WriteForeign value
  , ReadForeign value
  , Newtype value valueRecord
  , RecordKeysOverlap indexes valueRecord
  , ExtractIndexPaths indexes
  ) <=
  IsPair
    (key :: Type)
    (value :: Type)
    (valueRecord :: Type)
    (indexes :: Type)
    (sortRow :: Row Type)
    (singularName :: Symbol)
    (pluralName :: Symbol)
    (findEffSym :: Symbol)
    (proj :: Type)
  | value -> key
  , key -> value
  , key value -> singularName
  , key value -> pluralName
  , key value -> findEffSym
  , key value -> proj
  , key value -> valueRecord
  , key value -> indexes
  , key value -> sortRow
  where
  toKey :: value -> key

  single :: Boolean

persistenceKeyFromValue
  :: ∀ singularName pluralName key value
   . IsPair key value _ _ _ singularName pluralName _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => value
  -> Key
persistenceKeyFromValue v =
  let
    ka = toAliasedPrimary (toKey v)
  in
    Key
      { singularType: ᴠ @singularName
      , pluralType: ᴠ @pluralName
      , primary: single @key ? Nothing ↔ (if ka.primary == "" then Nothing else Just ka.primary)
      , aliases: single @key ? [] ↔ ka.aliases
      }

persistenceKeyFromKey
  :: ∀ singularName pluralName key value
   . IsPair key value _ _ _ singularName pluralName _ _
  => IsSymbol singularName
  => IsSymbol pluralName
  => key
  -> Key
persistenceKeyFromKey k =
  let
    ka = toAliasedPrimary k
  in
    Key
      { singularType: ᴠ @singularName
      , pluralType: ᴠ @pluralName
      , primary: single @key ? Nothing ↔ (if ka.primary == "" then Nothing else Just ka.primary)
      , aliases: single @key ? [] ↔ ka.aliases
      }
