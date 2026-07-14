module Core.Mod.Projection.Finder.Sort where

import Yoga.JSON as SimpleJSON
import Foreign as Foreign
import Proem
import Yoga.JSON as Yoga.JSON
import Control.Monad.Except as Control.Monad.Except

import Core.Mod.Projection.Pair (class IsPair)
import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Util.Validation (class IsRefinedType)
import Core.Mod.Projection.SearchIndex (IndexNeeds, Yes)
import Data.Argonaut.Decode (class DecodeJson, decodeJson)
import Data.Argonaut.Decode.Error (JsonDecodeError(..))
import Data.Argonaut.Encode (class EncodeJson, encodeJson)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype, unwrap)
import Data.Show.Generic (genericShow)
import Data.String as String
import Data.Symbol (class IsSymbol)
import Prim.Row as Row
import Util.Type.Row.HasNestedKey (class HasNestedKey)
import Data.Array as Array
import Util.Type.Row.Row (class ExtractRowKeys, extractRowKeys)
import Util.Type.Random (class Random, random)
import Effect.Random (randomInt)

by
  :: ∀ @field @value (sortRow :: Row Type) indexes fieldValue valueRecord (n :: Type) (f :: Type) (i :: Type)
   . IsPair _ value valueRecord indexes sortRow _ _ _ _
  => Newtype value valueRecord
  => HasNestedKey valueRecord field fieldValue
  => HasNestedKey indexes field (IndexNeeds Yes n f i fieldValue)
  => Row.Cons field Ɩ _ sortRow
  => IsSymbol field
  => SortDirection
  -> SortCriterion value
by direction =
  SortCriterion
    { path: String.split (String.Pattern ".") (ᴠ @field)
    , direction
    }

noSort :: ∀ a. SortCriteria a
noSort = []

data SortDirection = Asc | Desc

derive instance Eq SortDirection
derive instance Ord SortDirection
derive instance Generic SortDirection _
instance Show SortDirection where
  show = genericShow

instance EncodeJson SortDirection where
  encodeJson Asc = encodeJson "Asc"
  encodeJson Desc = encodeJson "Desc"

instance DecodeJson SortDirection where
  decodeJson json = do
    str <- decodeJson json
    case str of
      "Asc" -> Right Asc
      "Desc" -> Right Desc
      _ -> Left $ UnexpectedValue json

type SortCriterion_ =
  { path :: Array String
  , direction :: SortDirection
  }

newtype SortCriterion (value :: Type) = SortCriterion SortCriterion_

derive instance Newtype (SortCriterion value) _
derive newtype instance Eq (SortCriterion value)
derive newtype instance Show (SortCriterion value)

instance Random SortDirection where
  random = do
    i <- ʌ $ randomInt 0 1
    η $ if i == 0 then Asc else Desc

instance
  (IsPair _1 value _2 _3 sortRow _4 _5 _6 _7
  , ExtractRowKeys sortRow
  ) =>
  Random (SortCriterion value) where
  random = do
    let
      keys = extractRowKeys @sortRow
      maxIdx = Array.length keys - 1

    path <-
      if maxIdx < 0 then η []
      else do
        idx <- ʌ $ randomInt 0 maxIdx
        η $ String.split (String.Pattern ".") (Array.index keys idx ??⇒ "")

    direction <- random

    η $ SortCriterion { path, direction }

instance EncodeJson (SortCriterion value) where
  encodeJson = unwrap ▷ encodeJson

instance
  (IsPair _1 value _2 _3 sortRow _4 _5 _6 _7
  , ExtractRowKeys sortRow
  ) =>
  IsRefinedType (SortCriterion value) (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (SimpleJSON.readImpl json) of
    Right sort -> Right sort
    Left err -> Left $ inj (MalformedPayloadValue { innerPath: Nothing, error: err })

instance
  (IsPair _1 value _2 _3 sortRow _4 _5 _6 _7
  , ExtractRowKeys sortRow
  ) =>
  DecodeJson (SortCriterion value) where
  decodeJson json = do
    { path, direction } :: SortCriterion_ <- decodeJson json

    let pathStr = String.joinWith "." path

    if Array.elem pathStr (extractRowKeys @sortRow) then
      Right $ SortCriterion { path, direction }
    else
      Left $ TypeMismatch $ "Invalid sort field: " <> pathStr

type SortCriteria (value :: Type) = Array (SortCriterion value)


instance SimpleJSON.ReadForeign SortDirection where
  readImpl f = do
    str <- SimpleJSON.readImpl f
    case str of
      "Asc" -> pure Asc
      "Desc" -> pure Desc
      _ -> Foreign.fail (Foreign.ForeignError "Invalid SortDirection")

instance
  (IsPair _1 value _2 _3 sortRow _4 _5 _6 _7
  , ExtractRowKeys sortRow
  ) => SimpleJSON.ReadForeign (SortCriterion value) where
  readImpl f = do
    { path, direction } <- SimpleJSON.readImpl f :: _ { path :: Array String, direction :: SortDirection }
    let pathStr = String.joinWith "." path
    if Array.elem pathStr (extractRowKeys @sortRow) then
      pure $ SortCriterion { path, direction }
    else
      Foreign.fail (Foreign.ForeignError $ "Invalid sort field: " <> pathStr)

instance Yoga.JSON.WriteForeign SortDirection where
  writeImpl Asc = Yoga.JSON.writeImpl "Asc"
  writeImpl Desc = Yoga.JSON.writeImpl "Desc"

instance Yoga.JSON.WriteForeign (SortCriterion value) where
  writeImpl (SortCriterion { path, direction }) = Yoga.JSON.writeImpl { path, direction }
