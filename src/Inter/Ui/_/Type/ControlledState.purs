module Inter.Ui.Type.ControlledState where

import Proem

import Control.Monad.State (class MonadState, gets)
import Data.Lens (Lens', Prism', prism', (^.))
import Data.Maybe (Maybe(..))
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))

data ControlledState a = Controlled a | Uncontrolled a

derive instance Eq a => Eq (ControlledState a)
instance Show a => Show (ControlledState a) where
  show (Controlled a) = "(Controlled " <> show a <> ")"
  show (Uncontrolled a) = "(Uncontrolled " <> show a <> ")"

_Controlled :: ∀ a. Prism' (ControlledState a) a
_Controlled = prism' Controlled case _ of
  Controlled c -> Just c
  _ -> Nothing

_Uncontrolled :: ∀ a. Prism' (ControlledState a) a
_Uncontrolled = prism' Uncontrolled case _ of
  Uncontrolled c -> Just c
  _ -> Nothing

shouldUseControlledPrism_ :: ∀ a. IntentOrigin -> ControlledState a -> Boolean
shouldUseControlledPrism_ intentOrigin controlled' =
  let
    controlled = case controlled' of
      Controlled _ -> true
      Uncontrolled _ -> false
  in
    case intentOrigin of
      External -> controlled
      Internal -> false

shouldUseControlledPrism :: ∀ m s a. MonadState s m => IntentOrigin -> Lens' s (ControlledState a) -> m Boolean
shouldUseControlledPrism intentOrigin givenPath = do
  controlled' <- gets (_ ^. givenPath)
  η $ shouldUseControlledPrism_ intentOrigin controlled'
