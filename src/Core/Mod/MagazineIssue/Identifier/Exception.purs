module Core.Mod.MagazineIssue.Identifier.Exception where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type IdentifierExceptionRow r = ("Core.Mod.MagazineIssue.Identifier.Exception" ∷ InvalidMagazineIssueIdentifier | r)

newtype InvalidMagazineIssueIdentifier = InvalidMagazineIssueIdentifier String

derive newtype instance Show InvalidMagazineIssueIdentifier
derive newtype instance Eq InvalidMagazineIssueIdentifier

instance Reflect InvalidMagazineIssueIdentifier where
  reflectName = "InvalidMagazineIssueIdentifier"

instance IsLogicException InvalidMagazineIssueIdentifier (IdentifierExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.MagazineIssue.Identifier.Exception")

instance Translate InvalidMagazineIssueIdentifier where
  translate En (InvalidMagazineIssueIdentifier payload) = "Invalid magazine issue identifier format: " <> payload
  translate Fr (InvalidMagazineIssueIdentifier payload) = "Format d'identifiant de magazine invalide : " <> payload
