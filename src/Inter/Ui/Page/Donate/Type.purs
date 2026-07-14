module Inter.Ui.Page.Donate.Type where

import Halogen (HalogenM, ForkId)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.Type.Output (NoOutput)
import Data.Maybe (Maybe)

import Halogen.Store.Connect (Connected)

type Input = Connected Boolean {}

type Output = NoOutput

type Slots :: ∀ k. Row k
type Slots = ()

type State = { isLoggedIn :: Boolean, pollForkId :: Maybe ForkId }

data Action
  = Receive Input
  | OpenLoginModal
  | Initialize
  | Finalize


type Query :: ∀ k. k -> Type
type Query = NoQuery

type DonateM a = HalogenM State Action Slots Output UiM a
