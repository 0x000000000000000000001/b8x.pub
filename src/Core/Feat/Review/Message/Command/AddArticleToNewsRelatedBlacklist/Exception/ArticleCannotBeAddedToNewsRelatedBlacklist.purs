module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Exception.ArticleCannotBeAddedToNewsRelatedBlacklist where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data ArticleCannotBeAddedToNewsRelatedBlacklist = ArticleCannotBeAddedToNewsRelatedBlacklist

type ArticleCannotBeAddedToNewsRelatedBlacklistRow r =
  ("Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Exception.ArticleCannotBeAddedToNewsRelatedBlacklist" ∷ ArticleCannotBeAddedToNewsRelatedBlacklist
  | r
  )

instance Reflect ArticleCannotBeAddedToNewsRelatedBlacklist where
  reflectName = "ArticleCannotBeAddedToNewsRelatedBlacklist"

instance IsLogicException ArticleCannotBeAddedToNewsRelatedBlacklist (ArticleCannotBeAddedToNewsRelatedBlacklistRow r) where
  inj = Variant.inj (π @"Core.Feat.Review.Message.Command.AddArticleToNewsRelatedBlacklist.Exception.ArticleCannotBeAddedToNewsRelatedBlacklist")

instance Translate ArticleCannotBeAddedToNewsRelatedBlacklist where
  translate En _ = "Article cannot be added to news related blacklist."
  translate Fr _ = "L'article ne peut pas être ajouté à la liste blanche associée aux actualités."
