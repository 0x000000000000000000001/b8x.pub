module Core.Message.Field.Exception.MissingField where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)
import Data.String as String

type Path = Array String

type MissingFieldExceptionRow r =
  ("Core.Message.Field.Exception.MissingField" ∷ MissingField
  | r
  )

newtype MissingField = MissingField Path

instance Reflect MissingField where
  reflectName = "MissingField"

instance IsLogicException MissingField (MissingFieldExceptionRow r) where
  inj = Variant.inj (π @"Core.Message.Field.Exception.MissingField")

instance Translate MissingField where
  translate En (MissingField path) =
    let
      pathStr = String.joinWith "." path
    in
      "Field \"" <> pathStr <> "\" is missing"
  translate Fr (MissingField path) =
    let
      pathStr = String.joinWith "." path
    in
      "Champ \"" <> pathStr <> "\" manquant"
