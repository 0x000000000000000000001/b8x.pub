module Core.Message.Field.Field where

import Proem
import Control.Monad.Except as Control.Monad.Except

import Data.Enum (class BoundedEnum, enumFromTo)

import Foreign (Foreign)
import Foreign as Foreign
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.String (trim)
import Core.Message.MakeMessageM (MakeMessageM)

type FieldCli =
  { description :: String
  , multiline :: Boolean
  , choices :: Maybe (Array String)
  }

type DefaultDescription = String

data Sanitized a
  = ConsideredMissingSoShouldBeDefault
  | Intact
  | CorrectedJson Foreign -- When you want to provide the correct encoded value.
  | Corrected a -- When you want to provide the correct decoded value.

data Presence a
  = Required
  | Optional (MakeMessageM a) DefaultDescription

class
  ( Newtype field a
  , ReadForeign field
  , WriteForeign field
  , WriteForeign a
  ) <=
  IsField
    field
    a
    (children :: Row Type)
  | field -> a
  , field -> children
  where
  name :: String

  description :: String

  presence :: Presence a

  sanitize :: Foreign -> Sanitized a

  shouldSanitizeInner :: Boolean -- Should we call a's sanitize?

  cli :: FieldCli

maybePresence :: ∀ a. String -> Presence (Maybe a)
maybePresence description = Optional (η Nothing) description

defaultMaybePresence :: ∀ a. Presence (Maybe a)
defaultMaybePresence = maybePresence "None"

defaultSanitize :: ∀ a. Sanitized a -> Foreign -> Sanitized a
defaultSanitize fallback json =
  if Foreign.isNull json || Foreign.isUndefined json then fallback
  else case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Intact
    Right str -> trim str == "" ? fallback ↔ Intact

defaultShouldSanitizeInner :: Boolean
defaultShouldSanitizeInner = true

enumChoices :: ∀ @a. BoundedEnum a => Show a => Array String
enumChoices = show <$> (enumFromTo bottom top :: Array a)
