module Inter.Ui.Router.PrettyBackground.Firefly.Type where

import Data.Maybe (Maybe)
import Halogen (HalogenM)
import Inter.Ui.Router.PrettyBackground.Firefly.Util (Cancel)
import Inter.Ui.Type.Input (NoInput)
import Inter.Ui.Type.Output (NoOutput)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.UiM (UiM)

type Input = NoInput

type Output = NoOutput

type Slots :: Row Type
type Slots = ()

type State =
  { cleanup :: Maybe Cancel
  }

data Action
  = Initialize
  | Finalize

type Query :: ∀ k. k -> Type
type Query = NoQuery

type FireflyM a = HalogenM State Action Slots Output UiM a
