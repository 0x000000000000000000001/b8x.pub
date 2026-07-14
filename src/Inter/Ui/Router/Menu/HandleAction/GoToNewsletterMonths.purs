module Inter.Ui.Router.Menu.HandleAction.GoToNewsletterMonths where

import Proem

import Core.Mod.Time.Year (Year)
import Data.Lens ((.~))
import Halogen (modify_)

import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.State.State (_newsletter)
import Inter.Ui.Router.Menu.Type.State.Newsletter as Newsletter
import Inter.Ui.Router.Menu.Type.State.Newsletter (_page)
import Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu)

goToNewsletterMonths :: Year -> MenuM Ɩ
goToNewsletterMonths year = do
  modify_ (_newsletter ◁ _page .~ Newsletter.Months { year })
  scrollTopMenu
