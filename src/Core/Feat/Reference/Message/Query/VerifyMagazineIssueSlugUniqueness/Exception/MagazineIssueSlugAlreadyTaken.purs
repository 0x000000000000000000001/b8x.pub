module Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Exception.MagazineIssueSlugAlreadyTaken where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Data.Variant as Variant
import Util.Type.String.ToString (toString)
import Util.Type.Type (class Reflect)

newtype MagazineIssueSlugAlreadyTaken = MagazineIssueSlugAlreadyTaken Slug

derive newtype instance Show MagazineIssueSlugAlreadyTaken
derive newtype instance Eq MagazineIssueSlugAlreadyTaken

instance Reflect MagazineIssueSlugAlreadyTaken where
  reflectName = "MagazineIssueSlugAlreadyTaken"

type MagazineIssueSlugAlreadyTakenRow r =
  ("Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Exception.MagazineIssueSlugAlreadyTaken" ∷ MagazineIssueSlugAlreadyTaken
  | r
  )

instance IsLogicException MagazineIssueSlugAlreadyTaken (MagazineIssueSlugAlreadyTakenRow r) where
  inj = Variant.inj (π @"Core.Feat.Reference.Message.Query.VerifyMagazineIssueSlugUniqueness.Exception.MagazineIssueSlugAlreadyTaken")

instance Translate MagazineIssueSlugAlreadyTaken where
  translate En (MagazineIssueSlugAlreadyTaken slug) = "A magazine issue with slug \"" <> toString slug <> "\" already exists"
  translate Fr (MagazineIssueSlugAlreadyTaken slug) = "Un magazine avec le slug \"" <> toString slug <> "\" existe déjà"
