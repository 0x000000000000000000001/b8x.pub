module Core.Mod.Editor.Name.Message.Field where

import Data.Maybe (Maybe(..))

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.Editor.Name.Name as Base
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.String (trim)
import Util.Type.String.String (collapseSpaces)

type Name = Base.Name

newtype NameField = NameField Name

description :: String
description = "Editor name"

instance IsField NameField Name () where
  name = "Name"

  description = description

  presence = Required

  sanitize json = case Control.Monad.Except.runExcept (readImpl json) of
    Right str -> CorrectedJson $ writeImpl $ str # collapseSpaces false # trim
    Left _ -> Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype NameField _
derive newtype instance ReadForeign NameField
derive newtype instance WriteForeign NameField
derive newtype instance Eq NameField
derive newtype instance Show NameField

