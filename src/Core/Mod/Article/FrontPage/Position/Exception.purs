module Core.Mod.Article.FrontPage.Position.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

newtype InvalidPosition = InvalidPosition String

derive newtype instance Show InvalidPosition

type PositionExceptionRow r =
  ("Core.Mod.Article.FrontPage.Position.Exception" ∷ InvalidPosition
  | r
  )

instance Reflect InvalidPosition where
  reflectName = "InvalidPosition"

instance IsLogicException InvalidPosition (PositionExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.FrontPage.Position.Exception")

instance Translate InvalidPosition where
  translate En (InvalidPosition str) = "Invalid front page position: " <> str
  translate Fr (InvalidPosition str) = "Position à la une invalide : " <> str
