module Inter.Ui.Mod.Modal.Type
  (Action(..)
  , Input
  , ModalM
  , Output(..)
  , Query
  , Slots
  , State
  ) where

import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.Type.Slot (NoSlotAddressIndex)
import Inter.Ui.Type.State (WithId)
import Inter.Ui.UiM (UiM)
import Halogen (HalogenM, Slot)
import Web.UIEvent.MouseEvent (MouseEvent)
import Data.Maybe (Maybe)

type Input i =
  { closable :: Boolean
  -- Better than conditional rendering: in child-arrays, disappearing/reappearing 
  -- may slightly disturb the rerendering flow and the inner workings of 
  -- the siblings (e.g. ones with iframes)
  , open :: Boolean
  , background :: Maybe String
  , widthRem :: Maybe Number
  , innerInput :: i
  }

data Output o
  = Closed
  | InnerOutputRaised o

type Slots q o =
  (inner :: Slot q o NoSlotAddressIndex
  )

type State i = WithId
  (input :: Input i
  )

data Action i o
  = Initialize
  | Receive (Input i)
  | HandleClick MouseEvent
  | HandleCloseClick
  | RaiseInnerOutput o

type Query :: ∀ k. k -> Type
type Query = NoQuery

type ModalM q i o a = HalogenM (State i) (Action i o) (Slots q o) (Output o) UiM a
