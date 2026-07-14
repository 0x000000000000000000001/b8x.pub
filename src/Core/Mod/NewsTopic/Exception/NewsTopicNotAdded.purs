module Core.Mod.NewsTopic.Exception.NewsTopicNotAdded where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Core.Mod.NewsTopic.Id.Id (NewsTopicId)
import Data.Variant as Variant
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype NewsTopicNotAdded = NewsTopicNotAdded NewsTopicId

derive newtype instance Show NewsTopicNotAdded

type NewsTopicNotAddedRow r =
  ("Core.Mod.NewsTopic.Exception.NewsTopicNotAdded" ∷ NewsTopicNotAdded
  | r
  )

instance Reflect NewsTopicNotAdded where
  reflectName = "NewsTopicNotAdded"

instance IsLogicException NewsTopicNotAdded (NewsTopicNotAddedRow r) where
  inj = Variant.inj (π @"Core.Mod.NewsTopic.Exception.NewsTopicNotAdded")

instance Translate NewsTopicNotAdded where
  translate En (NewsTopicNotAdded id) = "News topic with ID \"" <> toString id <> "\" not added"
  translate Fr (NewsTopicNotAdded id) = "Sujet d'actualité avec l'ID \"" <> toString id <> "\" non ajouté"
