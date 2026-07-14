module Core.Message.Query.Payload where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Exception.Exception (inj)
import Core.Message.Exception.MalformedPayloadValue (MalformedPayloadValue(..), MalformedPayloadValueRow)
import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Util.Validation (class IsRefinedType, makeFromJson)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Foreign.Index (readProp)
import Foreign (Foreign)
import Foreign as Foreign
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Util.Type.Random (class Random, random)
import Yoga.JSON as JSON

-- Need

data Need opt innerNeeds = Needed opt innerNeeds | NotNeeded

derive instance Generic (Need opt innerNeeds) _

instance (Random opt, Random innerNeeds) => Random (Need opt innerNeeds) where
  random = do
    b <- random @Boolean
    if b then Needed <$> random <*> random else η NotNeeded

class WriteForeignOrUnit a where
  writeForeignOrUnit :: a -> Foreign

instance WriteForeignOrUnit Unit where
  writeForeignOrUnit _ = JSON.writeImpl ([] :: Array Foreign)
else instance WriteForeign a => WriteForeignOrUnit a where
  writeForeignOrUnit a = writeImpl a

instance (WriteForeignOrUnit opt, WriteForeignOrUnit innerNeeds) => WriteForeign (Need opt innerNeeds) where
  writeImpl (Needed opt innerNeeds) = JSON.writeImpl { type: "Needed", value: [ writeForeignOrUnit opt, writeForeignOrUnit innerNeeds ] }
  writeImpl NotNeeded = JSON.writeImpl { type: "NotNeeded", value: [] :: Array Foreign }
else instance WriteForeign b => WriteForeign (Need Unit b) where
  writeImpl (Needed _ innerNeeds) = JSON.writeImpl { type: "Needed", value: [ JSON.writeImpl ([] :: Array Foreign), writeImpl innerNeeds ] }
  writeImpl NotNeeded = JSON.writeImpl { type: "NotNeeded", value: [] :: Array Foreign }
else instance WriteForeign a => WriteForeign (Need a Unit) where
  writeImpl (Needed opt _) = JSON.writeImpl { type: "Needed", value: [ writeImpl opt, JSON.writeImpl ([] :: Array Foreign) ] }
  writeImpl NotNeeded = JSON.writeImpl { type: "NotNeeded", value: [] :: Array Foreign }
else instance (WriteForeign a, WriteForeign b) => WriteForeign (Need a b) where
  writeImpl (Needed opt innerNeeds) = JSON.writeImpl { type: "Needed", value: [ writeImpl opt, writeImpl innerNeeds ] }
  writeImpl NotNeeded = JSON.writeImpl { type: "NotNeeded", value: [] :: Array Foreign }

class ReadForeignOrUnit a where
  readForeignOrUnit :: Foreign -> Foreign.F a

instance ReadForeignOrUnit Unit where
  readForeignOrUnit _ = pure unit
else instance ReadForeign a => ReadForeignOrUnit a where
  readForeignOrUnit f = readImpl f

instance (ReadForeignOrUnit opt, ReadForeignOrUnit innerNeeds) => ReadForeign (Need opt innerNeeds) where
  readImpl json = do
    obj <- readImpl json
    typ <- readProp "type" obj >>= readImpl
    case typ of
      "Needed" -> do
        values <- readProp "value" obj >>= readImpl
        case values of
          [ opt, innerNeeds ] -> Needed <$> readForeignOrUnit opt <*> readForeignOrUnit innerNeeds
          _ -> Foreign.fail (Foreign.ForeignError "UnexpectedValue")
      "NotNeeded" -> pure NotNeeded
      _ -> Foreign.fail (Foreign.ForeignError "UnexpectedValue")

newtype NeedField opt innerNeeds = NeedField (Need opt innerNeeds)

derive instance Newtype (NeedField opt innerNeeds) _
derive newtype instance (WriteForeignOrUnit opt, WriteForeignOrUnit innerNeeds) => WriteForeign (NeedField opt innerNeeds)
derive newtype instance (ReadForeignOrUnit opt, ReadForeignOrUnit innerNeeds) => ReadForeign (NeedField opt innerNeeds)
derive newtype instance (Random opt, Random innerNeeds) => Random (NeedField opt innerNeeds)
derive instance (Eq opt, Eq innerNeeds) => Eq (Need opt innerNeeds)
instance (Show opt, Show innerNeeds) => Show (Need opt innerNeeds) where
  show = genericShow

derive newtype instance (Eq opt, Eq innerNeeds) => Eq (NeedField opt innerNeeds)
derive newtype instance (Show opt, Show innerNeeds) => Show (NeedField opt innerNeeds)

instance (ReadForeignOrUnit a, WriteForeignOrUnit a, Random a, Eq a, Show a, ReadForeignOrUnit b, WriteForeignOrUnit b, Random b, Eq b, Show b) => IsRefinedType (Need a b) (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl @(Need a b) json) of
    Right res -> Right res
    Left err -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error: err }

instance (ReadForeignOrUnit a, WriteForeignOrUnit a, Random a, Eq a, Show a, ReadForeignOrUnit b, WriteForeignOrUnit b, Random b, Eq b, Show b) => IsRefinedType (NeedField a b) (MalformedPayloadValueRow ()) where
  makeFromJson sanitize json = NeedField <$> makeFromJson sanitize json

description :: String
description = "Needed or not?"

instance (ReadForeignOrUnit opt, WriteForeignOrUnit opt, ReadForeignOrUnit innerNeeds, WriteForeignOrUnit innerNeeds) => IsField (NeedField opt innerNeeds) (Need opt innerNeeds) () where
  name = "Need"

  description = description

  presence = Optional (η NotNeeded) "Not needed"

  sanitize = defaultSanitize ConsideredMissingSoShouldBeDefault

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

-- Fold 

data Fold opt = Folded | Unfolded opt

derive instance Functor Fold
derive instance Generic (Fold opt) _
derive instance Eq opt => Eq (Fold opt)

instance Show opt => Show (Fold opt) where
  show = genericShow

instance WriteForeignOrUnit opt => WriteForeign (Fold opt) where
  writeImpl Folded = JSON.writeImpl { type: "Folded" }
  writeImpl (Unfolded opt) = JSON.writeImpl { type: "Unfolded", value: writeForeignOrUnit opt }

instance ReadForeignOrUnit opt => ReadForeign (Fold opt) where
  readImpl json = do
    obj <- readImpl json
    typ <- readProp "type" obj >>= readImpl
    case typ of
      "Folded" -> pure Folded
      "Unfolded" -> do
        opt <- readProp "value" obj >>= readForeignOrUnit
        η (Unfolded opt)
      _ -> Foreign.fail (Foreign.ForeignError "UnexpectedValue")

instance Random opt => Random (Fold opt) where
  random = do
    b <- random @Boolean
    b ? η Folded ↔ (Unfolded <$> random)

instance (ReadForeignOrUnit opt, WriteForeignOrUnit opt, Random opt, Eq opt, Show opt) => IsRefinedType (Fold opt) (MalformedPayloadValueRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl @(Fold opt) json) of
    Right res -> Right res
    Left err -> Left $ inj $ MalformedPayloadValue { innerPath: Nothing, error: err }
