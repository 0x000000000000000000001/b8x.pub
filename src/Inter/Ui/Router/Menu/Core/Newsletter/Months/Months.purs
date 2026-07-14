module Inter.Ui.Router.Menu.Core.Newsletter.Months.Months where

import Proem
import Data.Newtype (unwrap)

import Halogen (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Items.Item.Item (item)
import Inter.Ui.Router.Menu.Core.Newsletter.BackButton.BackButton (backButton)
import Inter.Ui.Router.Menu.Core.Newsletter.Style.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))
import Network.RemoteData (RemoteData(..))
import Core.Mod.Time.Year (Year)
import Core.Mod.Time.Month (Month(..))
import Data.Date.Component as Date
import Data.Array as Array
import Data.Map as Map
import Data.Tuple (Tuple(..))

translateMonth :: Date.Month -> String
translateMonth = case _ of
  Date.January -> "Janvier"
  Date.February -> "Février"
  Date.March -> "Mars"
  Date.April -> "Avril"
  Date.May -> "Mai"
  Date.June -> "Juin"
  Date.July -> "Juillet"
  Date.August -> "Août"
  Date.September -> "Septembre"
  Date.October -> "Octobre"
  Date.November -> "Novembre"
  Date.December -> "Décembre"

months :: State -> Year -> Array (ComponentHTML Action Slots UiM)
months state year = 
  [ backButton state OpenNewsletter "← Revenir aux années" 
  , Style.items_ state.id itemsArray
  ]
  where
  itemsArray = case state.newsletter.calendar of
    Success res -> 
      case Map.lookup year (unwrap res).calendar of
        Just monthsMap -> 
          let monthsDesc = Array.reverse (Map.toUnfoldable monthsMap)
          in map (\(Tuple m@(Month dm) _) -> item (translateMonth dm) Nothing (Just $ GoToNewsletterArticles year m Nothing false)) monthsDesc
        Nothing -> []
    _ -> []
