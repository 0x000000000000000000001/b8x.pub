module Core.Mod.NewsTopic.SearchInput.Message.Field where

import Data.Maybe (Maybe(..))

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.NewsTopic.SearchInput.SearchInput as Base
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.String (trim)
import Util.Type.String.String (collapseSpaces)

type SearchInput = Base.SearchInput

newtype SearchInputField = SearchInputField SearchInput

description :: String
description = "News topic search input"

instance IsField SearchInputField SearchInput () where
  name = "SearchInput"

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

derive instance Newtype SearchInputField _
derive newtype instance ReadForeign SearchInputField
derive newtype instance WriteForeign SearchInputField
derive newtype instance Eq SearchInputField
derive newtype instance Show SearchInputField

