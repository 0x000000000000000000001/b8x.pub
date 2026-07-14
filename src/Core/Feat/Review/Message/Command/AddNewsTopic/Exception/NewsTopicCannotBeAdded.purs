module Core.Feat.Review.Message.Command.AddNewsTopic.Exception.NewsTopicCannotBeAdded where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data NewsTopicCannotBeAdded = NewsTopicCannotBeAdded

type NewsTopicCannotBeAddedRow r =
  ("Core.Feat.Review.Message.Command.AddNewsTopic.Exception.NewsTopicCannotBeAdded" ∷ NewsTopicCannotBeAdded
  | r
  )

instance Reflect NewsTopicCannotBeAdded where
  reflectName = "NewsTopicCannotBeAdded"

instance IsLogicException NewsTopicCannotBeAdded (NewsTopicCannotBeAddedRow r) where
  inj = Variant.inj (π @"Core.Feat.Review.Message.Command.AddNewsTopic.Exception.NewsTopicCannotBeAdded")

instance Translate NewsTopicCannotBeAdded where
  translate En _ = "News topic cannot be added."
  translate Fr _ = "Le sujet d'actualité ne peut pas être ajouté."
