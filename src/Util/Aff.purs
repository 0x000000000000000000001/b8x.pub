module Util.Aff
  (ʌ'
  ) where

import Prelude

import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff, liftAff)

ʌ' :: ∀ m. MonadAff m => Aff ~> m
ʌ' = liftAff
