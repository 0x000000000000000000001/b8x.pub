module Core.Mod.Projection.Pair where

import Proem

import Core.Mod.Projection.SearchIndex (class ExtractIndexPaths)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Symbol (class IsSymbol)
import Util.Type.Row.Row (class RecordKeysOverlap)
import Data.Array.NonEmpty (NonEmptyArray)
import Data.Array.NonEmpty as NonEmptyArray

class ToPrimary a where
  toPrimary :: a -> String

class ToAliases a where
  toAliases :: a -> Array String

data KeyIdentifier
  = OnlyPrimary String
  | OnlyAliases (NonEmptyArray String)
  | AliasedPrimary String (NonEmptyArray String)

derive instance Eq KeyIdentifier
derive instance Ord KeyIdentifier
instance Show KeyIdentifier where
  show (OnlyPrimary p) = "(OnlyPrimary " <> show p <> ")"
  show (OnlyAliases a) = "(OnlyAliases " <> show a <> ")"
  show (AliasedPrimary p a) = "(AliasedPrimary " <> show p <> " " <> show a <> ")"

newtype Key = Key
  { singularType :: String
  , pluralType :: String
  , identifier :: Maybe KeyIdentifier
  }

getPrimary :: Key -> Maybe String
getPrimary (Key k) = case k.identifier of
  Just (OnlyPrimary p) -> Just p
  Just (AliasedPrimary p _) -> Just p
  _ -> Nothing

getAliases :: Key -> Array String
getAliases (Key k) = case k.identifier of
  Just (OnlyAliases a) -> NonEmptyArray.toArray a
  Just (AliasedPrimary _ a) -> NonEmptyArray.toArray a
  _ -> []

derive instance Eq Key
derive instance Ord Key

derive instance Newtype Key _
instance Show Key where
  show (Key k) = "Key { singularType: " <> show k.singularType <> ", pluralType: " <> show k.pluralType <> ", primary: " <> show (getPrimary (Key k)) <> ", aliases: " <> show (getAliases (Key k)) <> " }"

instance WriteForeign Key where
  writeImpl k@(Key obj) = writeImpl
    { singularType: obj.singularType
    , pluralType: obj.pluralType
    , primary: getPrimary k
    , aliases: getAliases k
    }

instance ReadForeign Key where
  readImpl json = do
    obj :: { singularType :: String, pluralType :: String, primary :: Maybe String, aliases :: Array String } <- readImpl json
    let
      mIdentifier = case obj.primary, NonEmptyArray.fromArray obj.aliases of
        Just p, Just a -> Just (AliasedPrimary p a)
        Just p, Nothing -> Just (OnlyPrimary p)
        Nothing, Just a -> Just (OnlyAliases a)
        Nothing, Nothing -> Nothing
    η $ Key
      { singularType: obj.singularType
      , pluralType: obj.pluralType
      , identifier: mIdentifier
      }

class
  ( ToPrimary key
  , ToAliases value
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
    primary_ = toPrimary (toKey v)
    aliases_ = toAliases v
    mPrimary = single @key ? Nothing ↔ (if primary_ == "" then Nothing else Just primary_)
    mAliases = single @key ? Nothing ↔ NonEmptyArray.fromArray aliases_
    
    mIdentifier = case mPrimary, mAliases of
      Just p, Just a -> Just (AliasedPrimary p a)
      Just p, Nothing -> Just (OnlyPrimary p)
      Nothing, Just a -> Just (OnlyAliases a)
      Nothing, Nothing -> Nothing
  in
    Key
      { singularType: ᴠ @singularName
      , pluralType: ᴠ @pluralName
      , identifier: mIdentifier
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
    primary_ = toPrimary k
    mPrimary = single @key ? Nothing ↔ (if primary_ == "" then Nothing else Just primary_)
    
    mIdentifier = case mPrimary of
      Just p -> Just (OnlyPrimary p)
      Nothing -> Nothing
  in
    Key
      { singularType: ᴠ @singularName
      , pluralType: ᴠ @pluralName
      , identifier: mIdentifier
      }
