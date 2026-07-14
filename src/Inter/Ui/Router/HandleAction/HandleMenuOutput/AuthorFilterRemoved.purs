module Inter.Ui.Router.HandleAction.HandleMenuOutput.AuthorFilterRemoved (handleMenuOutputAuthorFilterRemoved) where

import Proem

import Data.Maybe (Maybe(..))
import Halogen (gets)
import Inter.Ui.Capability.Navigate.Trans (navigate)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Router.Type (RouteM)

handleMenuOutputAuthorFilterRemoved :: RouteM Ɩ
handleMenuOutputAuthorFilterRemoved = do
  route <- gets _.route
  case route of
    Just (Home r) -> navigate (Home r { menu { search { withAuthorFilter = Nothing } } })
    Just (Theme slug r) -> navigate (Theme slug r { menu { search { withAuthorFilter = Nothing } } })
    Just (Article slug r) -> navigate (Article slug r { menu { search { withAuthorFilter = Nothing } } })
    Just (Donate r) -> navigate (Donate r { menu { search { withAuthorFilter = Nothing } } })
    Just NotFound -> ηι
    Nothing -> ηι
