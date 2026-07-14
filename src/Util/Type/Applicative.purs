module Util.Type.Applicative
  (η
  , ηι
  , κη
  , κηι
  , μ
  ) where

import Prelude

import Util.Function (κ, (◁))
import Util.Unit (Ɩ, ι)

η :: ∀ f a. Applicative f => a -> f a
η = pure

ηι :: ∀ f. Applicative f => f Ɩ
ηι = η ι

κηι :: ∀ f a. Applicative f => a -> f Ɩ
κηι = κ ηι

κη ∷ ∀ f a b. Applicative f => a -> b -> f a
κη = κ ◁ η

μ :: ∀ a m. Bind m => m (m a) -> m a
μ = join
