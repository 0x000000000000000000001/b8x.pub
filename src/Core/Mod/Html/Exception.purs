module Core.Mod.Html.Exception where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect)

type HtmlExceptionRow r = ("Core.Mod.Html.Exception" ∷ EmptyHtml | r)

data EmptyHtml = EmptyHtml

instance Reflect EmptyHtml where
  reflectName = "EmptyHtml"

instance IsLogicException EmptyHtml (HtmlExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.Html.Exception")

instance Translate EmptyHtml where
  translate En EmptyHtml = "Empty HTML"
  translate Fr EmptyHtml = "Le contenu HTML ne peut pas être vide"
