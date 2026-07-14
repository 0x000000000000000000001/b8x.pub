module Inter.Ui.Router.Menu.Core.Newsletter.Years.Years where

import Proem
import Data.Newtype (unwrap)
import Halogen (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Items.Item.Item (item)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Core.Newsletter.BackButton.BackButton (backButton)
import Inter.Ui.Router.Menu.Core.Newsletter.Style.Style as Style
import Inter.Ui.UiM (UiM)
import Data.Maybe (Maybe(..))
import Network.RemoteData (RemoteData(..))
import Util.Type.String.ToString (toString)
import Data.Enum (fromEnum)
import Core.Mod.Time.Year (Year(..))
import Data.Array as Array
import Data.Map as Map
import Data.Tuple (Tuple(..))

years :: State -> Array (ComponentHTML Action Slots UiM)
years state =
  [ backButton state CloseNewsletter "← Revenir au menu"
  , Style.items_ state.id (shortcuts <> itemsArray)
  ]
  where
  shortcuts = case state.newsletter.calendar of
    Success res ->
      let
        yearsDesc = Array.reverse (Map.toUnfoldable (unwrap res).calendar)
        flattened = Array.concatMap (\(Tuple year monthsMap) -> 
          let monthsDesc = Array.reverse (Map.toUnfoldable monthsMap)
          in Array.concatMap (\(Tuple month items) -> Array.reverse items <#> \i -> { year, month, id: i.id }) monthsDesc
        ) yearsDesc
      in
        case Array.take 2 flattened of
          [ n1, n2 ] ->
            [ item "Dernière en date" Nothing (Just $ GoToNewsletterArticles n1.year n1.month (Just n1.id) true)
            , item "Avant-dernière en date" Nothing (Just $ GoToNewsletterArticles n2.year n2.month (Just n2.id) true)
            ]
          [ n1 ] ->
            [ item "Dernière en date" Nothing (Just $ GoToNewsletterArticles n1.year n1.month (Just n1.id) true)
            ]
          _ -> []
    _ -> []

  itemsArray = case state.newsletter.calendar of
    Success res ->
      let
        yearsDesc = Array.reverse (Map.toUnfoldable (unwrap res).calendar)
      in
        map (\(Tuple y@(Year dy) _) -> item (toString (fromEnum dy)) Nothing (Just $ GoToNewsletterMonths y)) yearsDesc
    _ -> []
