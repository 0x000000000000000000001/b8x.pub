module Core.Mod.Article.Exception.ArticleSlugAlreadyTaken where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)
import Core.Mod.Article.Slug.Slug (Slug)
import Util.Type.String.ToString (toString)

newtype ArticleSlugAlreadyTaken = ArticleSlugAlreadyTaken Slug

type ArticleSlugAlreadyTakenRow r =
  ("Core.Mod.Article.Exception.ArticleSlugAlreadyTaken" ∷ ArticleSlugAlreadyTaken
  | r
  )

instance Reflect ArticleSlugAlreadyTaken where
  reflectName = "ArticleSlugAlreadyTaken"

instance IsLogicException ArticleSlugAlreadyTaken (ArticleSlugAlreadyTakenRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.Exception.ArticleSlugAlreadyTaken")

instance Translate ArticleSlugAlreadyTaken where
  translate En (ArticleSlugAlreadyTaken slug) = "An article with slug \"" <> toString slug <> "\" already exists"
  translate Fr (ArticleSlugAlreadyTaken slug) = "Un article avec le slug \"" <> toString slug <> "\" existe déjà"
