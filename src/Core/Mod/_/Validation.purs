module Core.Util.Validation where

import Proem
import Data.Either as Data.Either

import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Mod.Array.Exception (NotAnArray(..), ArrayExceptionRow)
import Core.Mod.Boolean.Exception (BooleanExceptionRow, NotABoolean(..))
import Core.Mod.Int.Exception (IntExceptionRow, NotAnInt(..))
import Foreign (Foreign)
import Foreign as Foreign
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Control.Monad.Except (runExcept)
import Util.NeedOpt (jsonNull)
import Data.Bifunctor (lmap)
import Data.Either (Either(..), note)
import Data.Int (fromNumber)
import Data.Maybe (Maybe(..))
import Data.Number (fromString) as Number
import Data.String (Pattern(..), Replacement(..), replaceAll, toLower)
import Data.Symbol (class IsSymbol)
import Data.Traversable (traverse)
import Data.Variant (Variant, expand)
import Foreign.Object as Object
import Prim.Row (class Lacks, class Union)
import Prim.Row as Row
import Prim.RowList (class RowToList, Nil, RowList)
import Prim.RowList as RowList
import Record.Builder (Builder)
import Record.Builder as Builder
import Type.Proxy (Proxy(..))
import Type.Row (type (+))
import Util.Type.Random (class Random)
import Util.Type.String.String (upperCaseFirst)
import Util.Type.Type (reflectVariantKeyName)
import Util.Type.Variant.Extract (class ExtractVariantImpl, extractVariant)

class (ReadForeign t, WriteForeign t, Random t, Eq t, Show t) <= IsRefinedType t (r :: Row Type) | t -> r where
  makeFromJson :: Boolean -> Foreign -> Either (Variant r) t

instance (IsRefinedType a r) => IsRefinedType (Maybe a) r where
  makeFromJson sanitize json =
    (Foreign.isNull json || Foreign.isUndefined json)
      ? (η Nothing)
      ↔ (Just <$> makeFromJson sanitize json)

instance (IsRefinedType a r, Union r rx (ArrayExceptionRow + r)) => IsRefinedType (Array a) (ArrayExceptionRow + r) where
  makeFromJson sanitize json = case runExcept (readImpl json) of
    Right arr -> case traverse (makeFromJson sanitize) arr of
      Right as -> Right as
      Left err -> Left (expand err)
    Left _ -> case runExcept (readImpl @a json) of
      Right a -> Right [ a ]
      Left _ -> Left $ inj NotAnArray

instance IsRefinedType Int (IntExceptionRow ()) where
  makeFromJson _ json =
    let
      handleInt i = Right i
      handleNumber n = note (inj NotAnInt) (fromNumber n)
      handleString s =
        let
          normalized = replaceAll (Pattern ",") (Replacement ".") s
        in
          case Number.fromString normalized of
            Just n -> handleNumber n
            Nothing -> Left $ inj NotAnInt
    in
      case runExcept (readImpl @Int json) of
        Right i -> handleInt i
        Left _ -> case runExcept (readImpl @Number json) of
          Right n -> handleNumber n
          Left _ -> case runExcept (readImpl @String json) of
            Right s -> handleString s
            Left _ -> Left $ inj NotAnInt

instance IsRefinedType Boolean (BooleanExceptionRow ()) where
  makeFromJson _ json =
    case Foreign.typeOf json of
      "boolean" -> case runExcept (Foreign.readBoolean json) of
          Right b -> Right b
          Left _ -> Left $ inj NotABoolean
      "number" -> case runExcept (Foreign.readNumber json) of
          Right 1.0 -> Right true
          Right 0.0 -> Right false
          _ -> Left $ inj NotABoolean
      "string" -> case toLower <$> runExcept (Foreign.readString json) of
          Right "true" -> Right true
          Right "1" -> Right true
          Right "yes" -> Right true
          Right "oui" -> Right true
          Right "y" -> Right true
          Right "o" -> Right true
          Right "false" -> Right false
          Right "no" -> Right false
          Right "non" -> Right false
          Right "n" -> Right false
          Right "0" -> Right false
          Right "" -> Right false
          _ -> Left $ inj NotABoolean
      "undefined" -> Right false
      _ ->
        if Foreign.isNull json then Right false
        else Left $ inj NotABoolean

makeRecordFromJson
  :: ∀ row rl
   . RowToList row rl
  => IsRefinedTypeRecord rl row
  => Boolean
  -> Foreign
  -> Either (Variant (MalformedPayloadValueRow ())) (Record row)
makeRecordFromJson sanitize json = do
  obj <- note (inj $ MalformedPayloadValue { innerPath: Nothing, error: pure (Foreign.ForeignError "Expected object") }) (Data.Either.hush $ runExcept (readImpl json :: Foreign.F (Object.Object Foreign)))
  builder <- makeRecordFromJsonBuilder @rl sanitize obj
  Right (Builder.build builder {})

class IsRefinedTypeRecord (rl :: RowList Type) (row :: Row Type) | rl -> row where
  makeRecordFromJsonBuilder :: Boolean -> Object.Object Foreign -> Either (Variant (MalformedPayloadValueRow ())) (Builder (Record ()) (Record row))

instance
  (IsSymbol sym
  , IsRefinedType ty tyErrs
  , RowToList tyErrs tyErrsRl
  , ExtractVariantImpl "malformedPayloadValue" MalformedPayloadValue tyErrsRl tyErrs
  , Row.Cons sym ty tailRow row
  , Lacks sym tailRow
  , IsRefinedTypeRecord tail tailRow
  ) =>
  IsRefinedTypeRecord (RowList.Cons sym ty tail) row where
  makeRecordFromJsonBuilder sanitize obj = do
    let
      sym = ᴠ @sym
      jsonValue = Object.lookup sym obj ??⇒ jsonNull

    parsedField <- lmap
      (\err ->
          case extractVariant (Proxy @"malformedPayloadValue") (Proxy @MalformedPayloadValue) err of
            Just (MalformedPayloadValue { innerPath, error }) ->
              let
                fullPath = case innerPath of
                  Just p -> Just (sym <> "." <> p)
                  Nothing -> Just sym
              in
                inj $ MalformedPayloadValue { innerPath: fullPath, error }
            Nothing ->
              let
                errTag = reflectVariantKeyName err
              in
                inj $ MalformedPayloadValue { innerPath: Just sym, error: pure (Foreign.ForeignError ("Invalid value (" <> upperCaseFirst errTag <> ")")) }
      )
      (makeFromJson @ty sanitize jsonValue)

    tailBuilder <- makeRecordFromJsonBuilder @tail sanitize obj

    Right $ Builder.insert (Proxy @sym) parsedField ◁ tailBuilder

instance IsRefinedTypeRecord Nil () where
  makeRecordFromJsonBuilder _ _ = Right identity
