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

import Inter.Ui.Type.Device (Device)

home :: Device -> Route -> ComponentHTML Action Slots UiM
home device route = HomeComponent.home { theme, context: device }
  where
  theme = case route of
    Theme t _ -> Just t
    _ -> Nothing
