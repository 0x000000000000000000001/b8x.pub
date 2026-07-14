module Core.Mod.MagazineIssue.Section.Section
  ( Section
  , SectionF(..)
  ) where

import Proem

import Core.Mod.MagazineIssue.CustomSection.Id.Id (CustomSectionId)
import Data.Foldable (class Foldable)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Traversable (class Traversable)
import Util.Json.TaggedSum (genericReadImplWithDefaultOpt, genericWriteImplWithDefaultOpt)
import Util.Type.Random (class Random, random)
import Yoga.JSON as Yoga.JSON

data SectionF custom
  = Intro
  | FeatureIntro
  | Feature
  | Custom custom

type Section = SectionF CustomSectionId

derive instance Functor SectionF
derive instance Foldable SectionF
derive instance Traversable SectionF
derive instance Eq custom => Eq (SectionF custom)
derive instance Ord custom => Ord (SectionF custom)
derive instance Generic (SectionF custom) _

instance Show custom => Show (SectionF custom) where
  show = genericShow

instance Random custom => Random (SectionF custom) where
  random = do
    v1 <- random
    v2 <- random
    case v1, v2 of
      true, true -> η Intro
      true, false -> η FeatureIntro
      false, true -> η Feature
      false, false -> Custom <$> random

instance Yoga.JSON.WriteForeign custom => Yoga.JSON.WriteForeign (SectionF custom) where
  writeImpl = genericWriteImplWithDefaultOpt

instance Yoga.JSON.ReadForeign custom => Yoga.JSON.ReadForeign (SectionF custom) where
  readImpl = genericReadImplWithDefaultOpt
