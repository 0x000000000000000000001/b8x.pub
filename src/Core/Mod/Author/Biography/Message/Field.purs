module Core.Mod.Author.Biography.Message.Field where

import Data.Maybe (Maybe(..))

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Field.Field (class IsField, Sanitized(..), defaultMaybePresence, defaultShouldSanitizeInner)
import Core.Mod.Author.Biography.Biography as Base
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Core.Mod.Html.Html (isEmpty)
import Util.Type.String.String (collapseSpaces, replaceReturnsAndTabsWithSpaces)

type Biography = Base.Biography

newtype BiographyField = BiographyField Biography

description :: String
description = "Author biography"

instance IsField BiographyField Biography () where
  name = "Bio"

  description = description

  presence = defaultMaybePresence

  sanitize json = case Control.Monad.Except.runExcept (readImpl json) of
    Left _ -> Intact
    Right str ->
      let
        str' = str # replaceReturnsAndTabsWithSpaces # collapseSpaces true
      in
        isEmpty str' ? ConsideredMissingSoShouldBeDefault ↔ (CorrectedJson $ writeImpl str')

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: true
    , choices: Nothing
    }

derive instance Newtype BiographyField _
derive newtype instance ReadForeign BiographyField
derive newtype instance WriteForeign BiographyField
derive newtype instance Eq BiographyField
derive newtype instance Show BiographyField
