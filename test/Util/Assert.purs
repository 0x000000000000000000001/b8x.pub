module Test.Util.Assert
  ( (<=?)
  , (<?)
  , (=?)
  , (>=?)
  , (>?)
  , shouldEqual
  , shouldGt
  , shouldGte
  , shouldLt
  , shouldLte
  ) where

import Proem

import Effect.Aff.Class (class MonadAff, liftAff)
import Test.Spec.Assertions (fail)

shouldEqual :: ∀ m t. MonadAff m => Show t => Eq t => t -> t -> m Unit
shouldEqual v1 v2 = liftAff $ do
  when (v1 /= v2) do
    let message = show v1 <> " ≠ " <> show v2
    fail message

infix 4 shouldEqual as =?

shouldGt :: ∀ m t. MonadAff m => Show t => Ord t => t -> t -> m Unit
shouldGt v1 v2 = liftAff $ do
  when (v1 <= v2) do
    let message = show v1 <> " ≤ " <> show v2
    fail message

infix 4 shouldGt as >?

shouldGte :: ∀ m t. MonadAff m => Show t => Ord t => t -> t -> m Unit
shouldGte v1 v2 = liftAff $ do
  when (v1 < v2) do
    let message = show v1 <> " < " <> show v2
    fail message

infix 4 shouldGte as >=?

shouldLt :: ∀ m t. MonadAff m => Show t => Ord t => t -> t -> m Unit
shouldLt v1 v2 = liftAff $ do
  when (v1 >= v2) do
    let message = show v1 <> " ≥ " <> show v2
    fail message

infix 4 shouldLt as <?

shouldLte :: ∀ m t. MonadAff m => Show t => Ord t => t -> t -> m Unit
shouldLte v1 v2 = liftAff $ do
  when (v1 > v2) do
    let message = show v1 <> " > " <> show v2
    fail message

infix 4 shouldLte as <=?
