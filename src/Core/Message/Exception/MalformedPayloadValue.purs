module Core.Message.Exception.MalformedPayloadValue where

import Proem
import Data.Maybe (Maybe, maybe)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

import Core.Exception.Exception (class IsLogicException)
import Util.I18n (class Translate, Language(..))
import Foreign (MultipleErrors)

newtype MalformedPayloadValue = MalformedPayloadValue
  { innerPath :: Maybe String -- Descendant path from this POV. Not the path of this, from root's POV.
  , error :: MultipleErrors
  }

derive instance Eq MalformedPayloadValue
derive instance Ord MalformedPayloadValue
derive newtype instance Show MalformedPayloadValue

instance Translate MalformedPayloadValue where
  translate En (MalformedPayloadValue { innerPath, error }) = "Malformed payload value" <> maybe "" (\p -> " at " <> p) innerPath <> ": " <> show error
  translate Fr (MalformedPayloadValue { innerPath, error }) = "Valeur du payload mal formatée" <> maybe "" (\p -> " à " <> p) innerPath <> " : " <> show error

instance Reflect MalformedPayloadValue where
  reflectName = "MalformedPayloadValue"

instance IsLogicException MalformedPayloadValue (MalformedPayloadValueRow r) where
  inj = Variant.inj (π @"Core.Message.Exception.MalformedPayloadValue")

type MalformedPayloadValueRow r =
  ("Core.Message.Exception.MalformedPayloadValue" ∷ MalformedPayloadValue
  | r
  )
