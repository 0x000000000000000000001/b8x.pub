module Core.Mod.Article.Exception.ArticleAlreadyWritten where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data ArticleAlreadyWritten = ArticleAlreadyWritten

type ArticleAlreadyWrittenRow r =
  ("Core.Mod.Article.Exception.ArticleAlreadyWritten" ∷ ArticleAlreadyWritten
  | r
  )

instance Reflect ArticleAlreadyWritten where
  reflectName = "ArticleAlreadyWritten"

instance IsLogicException ArticleAlreadyWritten (ArticleAlreadyWrittenRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.Exception.ArticleAlreadyWritten")

instance Translate ArticleAlreadyWritten where
  translate En _ = "Article already written"
  translate Fr _ = "Article déjà écrit"
