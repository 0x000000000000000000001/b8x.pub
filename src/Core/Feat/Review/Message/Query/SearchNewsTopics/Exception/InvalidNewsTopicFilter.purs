module Core.Feat.Review.Message.Query.SearchNewsTopics.Exception.InvalidNewsTopicFilter where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data InvalidNewsTopicFilter = InvalidNewsTopicFilter

type InvalidNewsTopicFilterRow r =
  ("Core.Mod.NewsTopic.Projection.Exception.InvalidNewsTopicFilter" ∷ InvalidNewsTopicFilter
  | r
  )

instance Reflect InvalidNewsTopicFilter where
  reflectName = "InvalidNewsTopicFilter"

instance IsLogicException InvalidNewsTopicFilter (InvalidNewsTopicFilterRow r) where
  inj = Variant.inj (π @"Core.Mod.NewsTopic.Projection.Exception.InvalidNewsTopicFilter")

instance Translate InvalidNewsTopicFilter where
  translate En _ = "Invalid filter for news topics"
  translate Fr _ = "Filtre invalide pour les sujets d'actualité"
