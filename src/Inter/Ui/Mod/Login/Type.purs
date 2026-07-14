module Inter.Ui.Mod.Login.Type
  ( Action(..)
  , Input
  , Output(..)
  , Query
  , Slots
  , State
  , LoginM
  ) where

import Inter.Ui.Mod.Input.Type.Output as Input
import Inter.Ui.Type.Slot (NoSlotAddressIndex)
import Inter.Ui.Mod.Input.Type.Query as InputQuery
import Halogen (HalogenM, Slot)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Type.Query (NoQuery)
import Web.Event.Event (Event)

type Input = {}

data Output = Close

type State =
  { email :: String
  , submitted :: Boolean
  , loading :: Boolean
  , invalidEmail :: Boolean
  }

data Action
  = Initialize
  | HandleEmailInput Input.Output
  | Submit Event

type Slots =
  ( input :: Slot InputQuery.Query Input.Output NoSlotAddressIndex
  )

type Query :: ∀ k. k -> Type
type Query = NoQuery

type LoginM a = HalogenM State Action Slots Output UiM a
