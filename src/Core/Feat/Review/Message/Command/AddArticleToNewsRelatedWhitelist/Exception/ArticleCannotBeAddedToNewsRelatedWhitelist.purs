module Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Exception.ArticleCannotBeAddedToNewsRelatedWhitelist where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data ArticleCannotBeAddedToNewsRelatedWhitelist = ArticleCannotBeAddedToNewsRelatedWhitelist

type ArticleCannotBeAddedToNewsRelatedWhitelistRow r =
  ("Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Exception.ArticleCannotBeAddedToNewsRelatedWhitelist" ∷ ArticleCannotBeAddedToNewsRelatedWhitelist
  | r
  )

instance Reflect ArticleCannotBeAddedToNewsRelatedWhitelist where
  reflectName = "ArticleCannotBeAddedToNewsRelatedWhitelist"

instance IsLogicException ArticleCannotBeAddedToNewsRelatedWhitelist (ArticleCannotBeAddedToNewsRelatedWhitelistRow r) where
  inj = Variant.inj (π @"Core.Feat.Review.Message.Command.AddArticleToNewsRelatedWhitelist.Exception.ArticleCannotBeAddedToNewsRelatedWhitelist")

instance Translate ArticleCannotBeAddedToNewsRelatedWhitelist where
  translate En _ = "Article cannot be added to news related whitelist."
  translate Fr _ = "L'article ne peut pas être ajouté à la liste blanche associée aux actualités."
