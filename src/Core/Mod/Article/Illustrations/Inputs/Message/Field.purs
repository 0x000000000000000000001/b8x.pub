module Core.Mod.Article.Illustrations.Inputs.Message.Field where

import Data.Maybe (Maybe(..))

import Proem

import Core.Message.Field.Field (class IsField, Presence(..), Sanitized(..), defaultSanitize, defaultShouldSanitizeInner)
import Core.Mod.Article.Illustrations.Illustrations (Illustration')
import Core.Mod.Article.Illustrations.Inputs.Caption.Message.Field (CaptionField)
import Core.Mod.Article.Illustrations.Inputs.Image.Message.Field (ImageField)
import Core.Mod.Article.Illustrations.Inputs.Inputs (Inputs) as Base
import Core.Mod.Url.Url (Url)
import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Newtype (class Newtype)
import Util.Type.Row.Row (recordKeysMatch)

type Inputs = Base.Inputs

newtype InputsField = InputsField Inputs

type InputsFieldChildren =
  (image :: ImageField
  , caption :: CaptionField
  )

check :: Q ConstraintPredicate
check = recordKeysMatch @(Record InputsFieldChildren) @(Illustration' Url)

description :: String
description = "Illustration inputs"

instance
  IsField
    InputsField
    Inputs
    InputsFieldChildren
  where
  name = "Inputs"

  description = description

  presence = Optional (η []) "None"

  sanitize = defaultSanitize (Corrected [])

  shouldSanitizeInner = defaultShouldSanitizeInner

  cli =
    { description
    , multiline: false
    , choices: Nothing
    }

derive instance Newtype InputsField _
derive newtype instance ReadForeign InputsField
derive newtype instance WriteForeign InputsField
derive newtype instance Eq InputsField
derive newtype instance Show InputsField
