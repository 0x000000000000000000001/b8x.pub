module Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu) where

import Proem
import Halogen (fork)
import Halogen as H
import Web.HTML.HTMLElement as HTMLElement
import Inter.Ui.Router.Menu.Core.Core as MenuCore
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Data.Maybe (Maybe(..))
import Util.Html.Dom.Dom as Dom

scrollTopMenu :: MenuM Ɩ
scrollTopMenu = do
  ø $ fork $ do
    mEl <- H.getHTMLElementRef MenuCore.ref
    case mEl of
      Just el -> Dom.scrollTopAll (HTMLElement.toElement el)
      Nothing -> ηι
