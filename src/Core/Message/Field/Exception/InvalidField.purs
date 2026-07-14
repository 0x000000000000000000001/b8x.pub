module Core.Message.Field.Exception.InvalidField where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Maybe (Maybe)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..), translate)
import Util.Type.Type (class Reflect)
import Data.String as String

type Path = Array String
type Value = String

type InvalidFieldExceptionRow e r =
  (invalidField :: InvalidField e
  | r
  )

data InvalidField e = InvalidField Path Value (Maybe e)

instance Reflect (InvalidField e) where
  reflectName = "InvalidField"

instance (Translate e) => IsLogicException (InvalidField e) (InvalidFieldExceptionRow e r) where
  inj = Variant.inj (π @"invalidField")

instance (Translate e) => Translate (InvalidField e) where
  translate lang (InvalidField path value e) =
    let
      pathStr = String.joinWith "." path
    in
      case lang of
        En -> "Problem with \"" <> pathStr <> "\": " <> (e ?? translate En ⇔ "Bad value \"" <> value <> "\"")
        Fr -> "Problème avec \"" <> pathStr <> "\" : " <> (e ?? translate Fr ⇔ "Mauvaise valeur \"" <> value <> "\"")
