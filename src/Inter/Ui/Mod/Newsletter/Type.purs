module Inter.Ui.Mod.Newsletter.Type where

import Proem

import Halogen (HalogenM, Slot)
import Web.Event.Event (Event)
import Inter.Ui.Type.Output (NoOutput)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.Input.Type.Query (Query) as Input
import Inter.Ui.Mod.Input.Type.Output (Output) as Input

data Status
  = Idle
  | Submitting
  | InvalidEmail
  | Failure
  | Success

derive instance Eq Status

type Input = Unit

type Output = NoOutput

type Slots =
  ( emailInput :: Slot Input.Query Input.Output Unit
  )

type State =
  { email :: String
  , status :: Status
  }

data Action
  = HandleInput Input.Output
  | Submit Event

type Query :: ∀ k. k -> Type
type Query = NoQuery

type NewsletterM a = HalogenM State Action Slots Output UiM a
