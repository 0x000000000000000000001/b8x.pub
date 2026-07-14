module Inter.Ui.Type.ControlledProp where

import Proem

import Data.Lens (Prism', prism')
import Data.Maybe (Maybe(..))

data ControlledProp a = Controlled a | Uncontrolled a

derive instance Eq a => Eq (ControlledProp a)
instance Show a => Show (ControlledProp a) where
  show (Controlled a) = "(Controlled " <> show a <> ")"
  show (Uncontrolled a) = "(Uncontrolled " <> show a <> ")"

_Controlled :: ∀ a. Prism' (ControlledProp a) a
_Controlled = prism' Controlled case _ of
  Controlled c -> Just c
  _ -> Nothing

_Uncontrolled :: ∀ a. Prism' (ControlledProp a) a
_Uncontrolled = prism' Uncontrolled case _ of
  Uncontrolled c -> Just c
  _ -> Nothing
