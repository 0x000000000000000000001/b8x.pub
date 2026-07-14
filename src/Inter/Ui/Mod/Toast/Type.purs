module Inter.Ui.Mod.Toast.Type where

import Proem

import Halogen.Subscription as HS
import Inter.Ui.Type.Toast (Toast)
import Data.Const (Const)

type Query :: ∀ k. k -> Type
type Query = Const Void

type Input = { toastEmitter :: HS.Emitter Toast }

type Output = Void

data ToastStatus = Entering | Active | Exiting
derive instance Eq ToastStatus

type State =
  { toasts :: Array { tId :: Int, version :: Int, toast :: Toast, status :: ToastStatus }
  , emitter :: HS.Emitter Toast
  , nextId :: Int
  }

data Action
  = Initialize
  | ReceiveToast Toast
  | StartRemoveToastInternal Int Int
  | RemoveToastInternal Int
  | ActivateToastInternal Int
