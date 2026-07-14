module Core.Mod.Article.Exception.ArticleNotWritten where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Core.Mod.Article.Id.Id (ArticleId)
import Data.Variant as Variant
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype ArticleNotWritten = ArticleNotWritten ArticleId

derive newtype instance Show ArticleNotWritten

type ArticleNotWrittenRow r =
  ("Core.Mod.Article.Exception.ArticleNotWritten" ∷ ArticleNotWritten
  | r
  )

instance Reflect ArticleNotWritten where
  reflectName = "ArticleNotWritten"

instance IsLogicException ArticleNotWritten (ArticleNotWrittenRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.Exception.ArticleNotWritten")

instance Translate ArticleNotWritten where
  translate En (ArticleNotWritten id) = "Article with ID \"" <> toString id <> "\" not referenced"
  translate Fr (ArticleNotWritten id) = "Article avec l'ID \"" <> toString id <> "\" non référencée"
