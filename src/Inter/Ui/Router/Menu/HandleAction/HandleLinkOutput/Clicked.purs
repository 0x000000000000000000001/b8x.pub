module Inter.Ui.Router.Menu.HandleAction.HandleLinkOutput.Clicked (handleLinkOutputClicked) where

import Proem

import Inter.Ui.Capability.Navigate.Navigate (Route)
import Inter.Ui.Router.Menu.HandleAction.Close (close)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Web.UIEvent.MouseEvent (MouseEvent)

handleLinkOutputClicked :: Route -> MouseEvent -> MenuM Ɩ
handleLinkOutputClicked _ _ = close External
