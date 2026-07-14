module Core.Message.Field.Payload where

import Proem
import Yoga.JSON as Yoga.JSON
import Control.Monad.Except as Control.Monad.Except

import Core.Exception.Exception (inj)
import Core.Exception.Index (LogicExceptionRow)
import Control.Monad.Except (throwError)
import Core.Message.Field.Exception.InvalidField (InvalidField(..))
import Core.Message.Field.Exception.MissingField (MissingField(..))
import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), presence, sanitize, shouldSanitizeInner)
import Core.Message.MakeMessageM (MakeMessageM)
import Core.Mod.Array.Exception (NotAnArray(..))
import Core.Util.Validation (class IsRefinedType)
import Core.Util.Validation as Validation
import Foreign (Foreign)
import Foreign as Foreign
import Yoga.JSON (readImpl, writeImpl)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (wrap)
import Data.Symbol (class IsSymbol)
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Variant (expand)
import Foreign.Object (Object)
import Foreign.Object as Object
import Prim.Row (class Union)
import Prim.Row as Row
import Prim.RowList (class RowToList, Cons, Nil, RowList)
import Record.Builder (Builder)
import Record.Builder as Builder
import Type.Equality (class TypeEquals, to)
import Util.Type.String.String (caseToCamel)

class MakePayload (fields :: Row Type) payload | fields -> payload where
  makePayload :: Object Foreign -> MakeMessageM payload

instance
  ( RowToList fields fieldsRowList
  , MakePayloadBuilderFromRowList fieldsRowList payloadRow
  , TypeEquals (Record payloadRow) payload
  ) =>
  MakePayload fields payload where
  makePayload json = do
    builder <- makePayloadBuilderFromRowList @fieldsRowList [] json
    η $ to $ Builder.buildFromScratch builder

class MakePayloadBuilderFromRowList (fieldsRowList :: RowList Type) (payloadRow :: Row Type) | fieldsRowList -> payloadRow where
  makePayloadBuilderFromRowList :: Array String -> Object Foreign -> MakeMessageM (Builder {} (Record payloadRow))

instance
  ( IsSymbol fieldName
  , IsField field a children
  , RowToList children childrenList
  , MakeFieldValue field a childrenList
  , MakePayloadBuilderFromRowList fieldsTail payloadRowTail
  , Row.Cons fieldName a payloadRowTail payloadRow
  , Row.Lacks fieldName payloadRowTail
  ) =>
  MakePayloadBuilderFromRowList (Cons fieldName field fieldsTail) payloadRow where
  makePayloadBuilderFromRowList path json = do
    tailBuilder <- makePayloadBuilderFromRowList @fieldsTail path json

    let
      fieldNameStr = ᴠ @fieldName

      currentPath = Array.snoc path (fieldNameStr # caseToCamel)

      make = makeFieldValue @field @a @childrenList currentPath

      handleSanitized val onMissing = case sanitize @field val of
        Intact -> make val
        CorrectedJson sanitizedJson -> make sanitizedJson
        Corrected sanitizedVal -> make (writeImpl sanitizedVal)
        ConsideredMissingSoShouldBeDefault -> onMissing

    lookupMake <- case presence @field of
      Required -> case Object.lookup fieldNameStr json of
        Nothing -> throwError ◁ wrap ◁ inj $ MissingField currentPath
        Just val ->
          handleSanitized val (throwError ◁ wrap ◁ inj $ InvalidField currentPath (Yoga.JSON.writeJSON val) Nothing)

      Optional default _ -> case Object.lookup fieldNameStr json of
        Nothing -> default
        Just val ->
          handleSanitized val default

    η $ tailBuilder ▷ Builder.insert (π :: Π fieldName) lookupMake

instance MakePayloadBuilderFromRowList Nil () where
  makePayloadBuilderFromRowList _ _ = η identity

class MakeFieldValue (field :: Type) (a :: Type) (childrenList :: RowList Type) where
  makeFieldValue
    :: Array String -- currentPath
    -> Foreign -- json
    -> MakeMessageM a

instance
  ( IsRefinedType a r
  , Union r rx LogicExceptionRow
  , IsField field (Array a) children
  ) =>
  MakeFieldValue field (Array a) Nil where
  makeFieldValue currentPath json =
    let
      shouldSanitizeInner' = shouldSanitizeInner @field
    in
      case Control.Monad.Except.runExcept (readImpl @(Array Foreign) json) of
        Right arr -> do
          let
            handleItem i el = case Validation.makeFromJson @a shouldSanitizeInner' el of
              Left e -> throwError ◁ wrap ◁ inj $ InvalidField (Array.snoc currentPath (show i)) (Yoga.JSON.writeJSON el) $ Just $ wrap $ expand e
              Right res -> η res
          traverseWithIndex handleItem arr
        Left _ -> case Validation.makeFromJson @a shouldSanitizeInner' json of
          Right res -> η [ res ]
          Left _ -> throwError ◁ wrap ◁ inj $ InvalidField currentPath (Yoga.JSON.writeJSON json) $ Just $ wrap $ inj NotAnArray

else instance
  ( IsRefinedType a r
  , Union r rx LogicExceptionRow
  , IsField field a children
  ) =>
  MakeFieldValue field a Nil where
  makeFieldValue currentPath json = case Validation.makeFromJson @a (shouldSanitizeInner @field) json of
    Left e -> throwError ◁ wrap ◁ inj $ InvalidField currentPath (Yoga.JSON.writeJSON json) $ Just $ wrap $ expand e
    Right res -> η res

instance
  ( MakePayloadBuilderFromRowList (Cons sym type_ tail) payloadRow
  , MakeNestedValue a (Record payloadRow)
  ) =>
  MakeFieldValue field (Array a) (Cons sym type_ tail) where
  makeFieldValue currentPath json = do
    case Control.Monad.Except.runExcept (readImpl @(Array Foreign) json) of
      Right arr -> do
        let
          handleItem i el = makeNestedValue @a @(Cons sym type_ tail) @payloadRow (Array.snoc currentPath (show i)) el
        traverseWithIndex handleItem arr
      Left _ -> do
        res <- makeNestedValue @a @(Cons sym type_ tail) @payloadRow (Array.snoc currentPath "0") json
        η [ res ]

else instance
  ( MakePayloadBuilderFromRowList (Cons sym type_ tail) payloadRow
  , MakeNestedValue a (Record payloadRow)
  ) =>
  MakeFieldValue field a (Cons sym type_ tail) where
  makeFieldValue currentPath json = makeNestedValue @a @(Cons sym type_ tail) @payloadRow currentPath json

makeNestedValue
  :: ∀ @a @fieldsRowList @payloadRow
   . MakePayloadBuilderFromRowList fieldsRowList payloadRow
  => MakeNestedValue a (Record payloadRow)
  => Array String
  -> Foreign
  -> MakeMessageM a
makeNestedValue currentPath json = do
  let
    buildRecord = case Control.Monad.Except.runExcept (readImpl json) of
      Left _ -> throwError ◁ wrap ◁ inj $ InvalidField currentPath (Yoga.JSON.writeJSON json) Nothing
      Right obj -> do
        builder <- makePayloadBuilderFromRowList @fieldsRowList currentPath obj
        η $ Builder.buildFromScratch builder
  makeNestedValue_ @a json buildRecord

class MakeNestedValue record' record | record' -> record where
  makeNestedValue_
    :: Foreign
    -> MakeMessageM record
    -> MakeMessageM record'

instance MakeNestedValue (Record row) (Record row) where
  makeNestedValue_ _ buildRecord = buildRecord

instance MakeNestedValue (Maybe (Record row)) (Record row) where
  makeNestedValue_ json buildRecord =
    if Foreign.isNull json then η Nothing
    else do
      res <- makeNestedValue_ @(Record row) json buildRecord
      η (Just res)
