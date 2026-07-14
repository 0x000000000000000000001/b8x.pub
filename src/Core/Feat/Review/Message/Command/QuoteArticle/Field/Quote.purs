module Core.Feat.Review.Message.Command.QuoteArticle.Field.Quote where

import Data.Maybe (Maybe(..))

import Proem
import Control.Monad.Except as Control.Monad.Except

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultShouldSanitizeInner)
import Core.Mod.NonEmptyString.NonEmptyString as Base
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl, writeImpl)
import Data.Either (Either(..))
import Data.Newtype (class Newtype)
import Data.String (trim)
import Util.Type.String.String (collapseSpaces)

type Quote = Base.NonEmptyString

newtype QuoteField = QuoteField Quote

description :: String
description = "Quote text (do not provide quotes yourself)"

instance IsField QuoteField Quote () where
  name = "Quote"

  description = description

  presence = Required

  sanitize json = case Control.Monad.Except.runExcept (readImpl json) of
    Right str -> CorrectedJson $ writeImpl $ str # collapseSpaces false # trim
    Left _ -> Intact

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: true
    , choices: Nothing
    }

derive instance Newtype QuoteField _
derive newtype instance ReadForeign QuoteField
derive newtype instance WriteForeign QuoteField
derive newtype instance Eq QuoteField
derive newtype instance Show QuoteField
