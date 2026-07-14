module Inter.Ui.Page.Home.Home
  (home
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Data.Maybe (Maybe(..))
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Page.Home.Component as HomeComponent
import Inter.Ui.Router.Type (Action, Slots)
import Inter.Ui.UiM (UiM)

home :: Route -> ComponentHTML Action Slots UiM
home route = HomeComponent.home { theme }
  where
  theme = case route of
    Theme t _ -> Just t
    _ -> Nothing
