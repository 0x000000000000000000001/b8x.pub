module Core.Mod.Article.FrontPage.Position.Position where

import Proem

import Control.Monad.Except as Control.Monad.Except
import Core.Exception.Exception (inj, throw')
import Core.Mod.Article.FrontPage.Position.Exception (InvalidPosition(..), PositionExceptionRow)
import Core.Util.Validation (class IsRefinedType)
import Data.Either (Either(..))
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Variant (Variant)
import Run (Run)
import Run.Except (Except)
import Util.Json.String (readStringImpl, writeStringImpl)
import Util.Type.Random (class Random)
import Util.Type.String.String (caseToSnake, normalizeForTextSearch)
import Util.Type.String.ToString (class FromString, class ToString)
import Yoga.JSON (class ReadForeign, class WriteForeign, readImpl)
import Yoga.JSON as Yoga.JSON

data Position
  = TopLeft
  | TopRight
  | Center
  | BottomLeft
  | BottomRight

derive instance Eq Position
derive instance Generic Position _

make_
  :: String
  -> Either (Variant (PositionExceptionRow ())) Position
make_ str = case str # caseToSnake # normalizeForTextSearch of
  "top left" -> Right TopLeft
  "top right" -> Right TopRight
  "center" -> Right Center
  "bottom left" -> Right BottomLeft
  "bottom right" -> Right BottomRight
  _ -> Left $ inj $ InvalidPosition str

make
  :: ∀ r n fx
   . Newtype n (Variant (PositionExceptionRow r))
  => String
  -> Run (exceptLogic ∷ Except n | fx) Position
make str = case make_ str of
  Left e -> throw' e
  Right loc -> η loc

instance IsRefinedType Position (PositionExceptionRow ()) where
  makeFromJson _ json = case Control.Monad.Except.runExcept (readImpl json) of
    Right str -> make_ str
    Left _ -> Left $ inj $ InvalidPosition $ Yoga.JSON.writeJSON json

instance Show Position where
  show TopLeft = "TopLeft"
  show TopRight = "TopRight"
  show Center = "Center"
  show BottomLeft = "BottomLeft"
  show BottomRight = "BottomRight"

instance ToString Position where
  toString = show

instance FromString Position where
  fromString "TopLeft" = Just TopLeft
  fromString "TopRight" = Just TopRight
  fromString "Center" = Just Center
  fromString "BottomLeft" = Just BottomLeft
  fromString "BottomRight" = Just BottomRight
  fromString _ = Nothing

instance WriteForeign Position where
  writeImpl = writeStringImpl

instance ReadForeign Position where
  readImpl = readStringImpl

instance Random Position where
  random = η TopLeft

