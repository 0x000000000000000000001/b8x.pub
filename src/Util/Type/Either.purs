module Util.Type.Either
  ((?!)
  , (?!⇽)
  , (?!⇾)
  , (⇿)
  , either
  , eitherLeft
  , eitherRight
  ) where

import Prelude (identity)

import Data.Either (Either)
import Data.Either as Either
import Data.Function (apply)

eitherLeft :: ∀ o l. Either l o -> (l -> o) -> o
eitherLeft e l = either e identity l

infixl 6 eitherLeft as ?!⇽

eitherRight :: ∀ o r. Either o r -> (r -> o) -> o
eitherRight e r = either e r identity

infixl 6 eitherRight as ?!⇾

either :: ∀ l r o. Either l r -> (r -> o) -> (l -> o) -> o
either e r l = Either.either l r e

infixl 1 either as ?!

infixr 0 apply as ⇿