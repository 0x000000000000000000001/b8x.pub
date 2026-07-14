module Core.Mod.Article.Theme.Theme where

import Control.Monad.Except as Control.Monad.Except
import Foreign as Foreign
import Yoga.JSON as Yoga.JSON
import Proem

import Data.Enum (class Enum, class BoundedEnum)
import Data.Enum.Generic (genericSucc, genericPred, genericCardinality, genericToEnum, genericFromEnum)
import Data.Bounded.Generic (genericBottom, genericTop)
import Core.Exception.Exception (inj, throw')
import Core.Mod.Article.Theme.Exception (InvalidTheme(..), ThemeExceptionRow)
import Core.Mod.Projection.SearchIndex (class IsScalar)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Maybe (Maybe(..))
import Data.Show.Generic (genericShow)
import Data.String (toLower, trim)
import Data.Variant (Variant)
import Run (Run)
import Run.Except (Except)
import Util.I18n (class Translate)
import Util.Type.Random (class Random, random)
import Util.Type.String.ToString (class FromString, class ToString, fromString, toString)

data Theme
  = Literature
  | Science
  | History
  | Ideas
  | Politics

derive instance Eq Theme
derive instance Ord Theme
derive instance Generic Theme _

instance IsScalar Theme

instance Show Theme where
  show = genericShow

instance ToString Theme where
  toString Literature = "literature"
  toString Science = "science"
  toString History = "history"
  toString Ideas = "ideas"
  toString Politics = "politics"

instance Translate Theme where
  translate _ Literature = "Art & Littérature"
  translate _ Science = "Science & Environnement"
  translate _ History = "Histoire"
  translate _ Ideas = "Idées, Philosophie & Religion"
  translate _ Politics = "Politique, Économie & Société"

instance FromString Theme where
  fromString = case _ of
    "literature" -> Just Literature
    "science" -> Just Science
    "history" -> Just History
    "ideas" -> Just Ideas
    "politics" -> Just Politics
    _ -> Nothing

sanitizeString :: String -> String
sanitizeString = trim ▷ toLower

make_
  :: Boolean
  -> String
  -> Either (Variant (ThemeExceptionRow ())) Theme
make_ sanitize str =
  let
    str' = sanitize ? (sanitizeString str) ↔ str
  in
    case fromString str' of
      Nothing -> Left $ inj $ InvalidTheme str
      Just t -> Right t

make
  :: ∀ r n fx
   . Newtype n (Variant (ThemeExceptionRow r))
  => Boolean
  -> String
  -> Run (exceptLogic ∷ Except n | fx) Theme
make sanitize str = case make_ sanitize str of
  Left e -> throw' e
  Right t -> η t

instance IsRefinedType Theme (ThemeExceptionRow ()) where
  makeFromJson sanitize json = case Control.Monad.Except.runExcept (Yoga.JSON.readImpl json) of
    Left _ -> Left $ inj $ InvalidTheme $ Yoga.JSON.writeJSON json
    Right str -> make_ sanitize str

instance Random Theme where
  random = do
    isLiterature <- random
    η $ isLiterature == true ? Literature ↔ Science

instance Bounded Theme where
  bottom = genericBottom
  top = genericTop

instance Enum Theme where
  succ = genericSucc
  pred = genericPred

instance BoundedEnum Theme where
  cardinality = genericCardinality
  toEnum = genericToEnum
  fromEnum = genericFromEnum


instance Yoga.JSON.ReadForeign Theme where
  readImpl f = do
    str <- Yoga.JSON.readImpl f
    case fromString str of
      Just t -> pure t
      Nothing -> Foreign.fail (Foreign.ForeignError "Invalid Theme")

instance Yoga.JSON.WriteForeign Theme where
  writeImpl t = Yoga.JSON.writeImpl (toString t)


