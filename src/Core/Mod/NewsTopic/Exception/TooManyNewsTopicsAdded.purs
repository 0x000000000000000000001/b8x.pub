module Core.Mod.NewsTopic.Exception.TooManyNewsTopicsAdded where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data TooManyNewsTopicsAdded = TooManyNewsTopicsAdded Int

type TooManyNewsTopicsAddedRow r =
  ("Core.Mod.NewsTopic.Exception.TooManyNewsTopicsAdded" ∷ TooManyNewsTopicsAdded
  | r
  )

instance Reflect TooManyNewsTopicsAdded where
  reflectName = "TooManyNewsTopicsAdded"

instance IsLogicException TooManyNewsTopicsAdded (TooManyNewsTopicsAddedRow r) where
  inj = Variant.inj (π @"Core.Mod.NewsTopic.Exception.TooManyNewsTopicsAdded")

instance Translate TooManyNewsTopicsAdded where
  translate En (TooManyNewsTopicsAdded limit) = "Too many news topics added (limit " <> show limit <> ")."
  translate Fr (TooManyNewsTopicsAdded limit) = "Trop de sujets d'actualité ajoutés (limite de " <> show limit <> ")."
