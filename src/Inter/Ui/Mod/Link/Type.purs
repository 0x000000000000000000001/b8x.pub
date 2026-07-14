module Inter.Ui.Mod.Link.Type
  ( Action(..)
  , LinkM
  , Input
  , Output(..)
  , Query
  , Slots
  , State
  , defaultInput
  ) where

import Proem

import Inter.Ui.Type.Children (Children)
import Inter.Ui.Type.Query (NoQuery)
import Inter.Ui.Type.Slot (NoSlots)
import Inter.Ui.Type.State (WithId)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import CSS (Display, inlineBlock)
import Data.Maybe (Maybe(..))
import Halogen (HalogenM)
import Web.UIEvent.MouseEvent (MouseEvent)

type Input =
  { route :: Maybe Route
  , classes :: Maybe (Array String)
  , display :: Display
  , children :: Children Action Slots
  }

defaultInput :: Input
defaultInput =
  { route: Just $ Home { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
  , classes: Nothing
  , display: inlineBlock
  , children: []
  }

data Output = Clicked Route MouseEvent

type Slots :: Row Type
type Slots = NoSlots

type State = WithId
  ( input :: Input
  )

data Action
  = Navigate Route
  | Receive Input
  | HandleClick Route MouseEvent

type Query :: ∀ k. k -> Type
type Query = NoQuery

type LinkM a = HalogenM State Action Slots Output UiM a
