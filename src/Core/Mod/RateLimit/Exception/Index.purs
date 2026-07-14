module Core.Mod.RateLimit.Exception.Index where

import Proem

import Util.I18n (class Translate, Language(..))
import Core.Exception.Exception (class IsLogicException)
import Data.Variant as Variant
import Util.Type.Type (class Reflect)

type RateLimitExceptionRow r =
  ("Core.Mod.RateLimit.Exception" ∷ RateLimitExceeded
  | r
  )

data RateLimitExceeded = RateLimitExceeded

derive instance Eq RateLimitExceeded

instance Reflect RateLimitExceeded where
  reflectName = "RateLimitExceeded"

instance IsLogicException RateLimitExceeded (RateLimitExceptionRow r) where
  inj = Variant.inj (π @"Core.Mod.RateLimit.Exception")

instance Translate RateLimitExceeded where
  translate En RateLimitExceeded = "Rate limit exceeded. Please try again later."
  translate Fr RateLimitExceeded = "Trop de requêtes. Veuillez réessayer plus tard."
