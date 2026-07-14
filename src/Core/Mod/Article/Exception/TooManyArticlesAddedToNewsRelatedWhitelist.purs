module Core.Mod.Article.Exception.TooManyArticlesAddedToNewsRelatedWhitelist where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data TooManyArticlesAddedToNewsRelatedWhitelist = TooManyArticlesAddedToNewsRelatedWhitelist Int

type TooManyArticlesAddedToNewsRelatedWhitelistRow r =
  ("Core.Mod.Article.Exception.TooManyArticlesAddedToNewsRelatedWhitelist" ∷ TooManyArticlesAddedToNewsRelatedWhitelist
  | r
  )

instance Reflect TooManyArticlesAddedToNewsRelatedWhitelist where
  reflectName = "TooManyArticlesAddedToNewsRelatedWhitelist"

instance IsLogicException TooManyArticlesAddedToNewsRelatedWhitelist (TooManyArticlesAddedToNewsRelatedWhitelistRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.Exception.TooManyArticlesAddedToNewsRelatedWhitelist")

instance Translate TooManyArticlesAddedToNewsRelatedWhitelist where
  translate En (TooManyArticlesAddedToNewsRelatedWhitelist limit) = "Too many articles added to news related whitelist (limit " <> show limit <> ")."
  translate Fr (TooManyArticlesAddedToNewsRelatedWhitelist limit) = "Trop d'articles ajoutés à la liste blanche associée aux actualités (limite de " <> show limit <> ")."
