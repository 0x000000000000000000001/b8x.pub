module Core.Mod.Article.LegacyId.Exception.LegacyIdAlreadyTaken where

import Proem

import Core.Exception.Exception (class IsLogicException)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Variant as Variant
import Util.I18n (class Translate, Language(..))
import Util.Type.Type (class Reflect, reflectConstructorName)

newtype LegacyIdAlreadyTaken = LegacyIdAlreadyTaken Int

derive instance Newtype LegacyIdAlreadyTaken _
derive instance Generic LegacyIdAlreadyTaken _
derive instance Eq LegacyIdAlreadyTaken
derive instance Ord LegacyIdAlreadyTaken

instance Reflect LegacyIdAlreadyTaken where
  reflectName = reflectConstructorName @LegacyIdAlreadyTaken

type LegacyIdAlreadyTakenRow r =
  ("Core.Mod.Article.LegacyId.Exception.LegacyIdAlreadyTaken" ∷ LegacyIdAlreadyTaken
  | r
  )

instance IsLogicException LegacyIdAlreadyTaken (LegacyIdAlreadyTakenRow r) where
  inj = Variant.inj (π @"Core.Mod.Article.LegacyId.Exception.LegacyIdAlreadyTaken")

instance Translate LegacyIdAlreadyTaken where
  translate En (LegacyIdAlreadyTaken id) = "Article legacy ID " <> show id <> " is already taken"
  translate Fr (LegacyIdAlreadyTaken id) = "L'ID de legacy " <> show id <> " est déjà pris"
