module Util.Effect
  (ʌ
  )
  where

import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)

ʌ :: ∀ m a. MonadEffect m => Effect a -> m a
ʌ = liftEffect