module Core.Mod.Newsletter.Exception.NewsletterAlreadyScheduled where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

data NewsletterAlreadyScheduled = NewsletterAlreadyScheduled

type NewsletterAlreadyScheduledRow r =
  ("Core.Mod.Newsletter.Exception.NewsletterAlreadyScheduled" ∷ NewsletterAlreadyScheduled
  | r
  )

instance Reflect NewsletterAlreadyScheduled where
  reflectName = "NewsletterAlreadyScheduled"

instance IsLogicException NewsletterAlreadyScheduled (NewsletterAlreadyScheduledRow r) where
  inj = Variant.inj (π @"Core.Mod.Newsletter.Exception.NewsletterAlreadyScheduled")

instance Translate NewsletterAlreadyScheduled where
  translate En _ = "Newsletter already scheduled."
  translate Fr _ = "Newsletter déjà planifiée."
