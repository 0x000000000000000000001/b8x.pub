module Inter.Ui.Router.Menu.Core.Magazine.Years.Years where

import Proem

import Halogen (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Items.Item.Item (item)
import Halogen.HTML (text)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Core.Magazine.BackButton.BackButton (backButton)
import Inter.Ui.Router.Menu.Core.Magazine.Style.Style as Style
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))
import Network.RemoteData (RemoteData(..))
import Util.Type.String.ToString (toString)
import Data.Enum (fromEnum)
import Core.Mod.Time.Year (Year(..))
import Data.Array as Array
import Data.Map as Map
import Data.Tuple (Tuple(..))
import Data.Newtype (unwrap)

years :: State -> Array (ComponentHTML Action Slots UiM)
years state =
  [ backButton state CloseMagazine [ text "← Revenir au menu" ]
  , Style.items_ state.id itemsArray
  ]
  where
  itemsArray = case state.magazine.calendar of
    Success res ->
      let
        yearsDesc = Array.reverse (Map.toUnfoldable (unwrap res).calendar)
      in
        map (\(Tuple y@(Year dy) _) -> item (toString (fromEnum dy)) Nothing (Just $ GoToMagazineCovers y)) yearsDesc
    _ -> []
