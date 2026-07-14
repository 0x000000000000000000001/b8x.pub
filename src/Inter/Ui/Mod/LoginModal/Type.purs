module Inter.Ui.Mod.LoginModal.Type where

import Inter.Ui.Type.Output (NoOutput)
import Inter.Ui.UiM (UiM)
import Halogen (HalogenM, Slot)
import Inter.Ui.Mod.Login.Type as Login
import Inter.Ui.Mod.Modal.Type as Modal

import Inter.Ui.Type.Slot (NoSlotAddressIndex)

import Halogen.Store.Connect (Connected)

type Input = Connected Boolean {}

type Output = NoOutput

type Slots =
  ( modal :: Slot Login.Query (Modal.Output Login.Output) NoSlotAddressIndex )

type State =
  { isOpen :: Boolean
  }

data Action
  = Initialize
  | Receive Input
  | HandleModalOutput (Modal.Output Login.Output)

data Query a
  = Open a
  | Close a

type LoginModalM a = HalogenM State Action Slots Output UiM a
