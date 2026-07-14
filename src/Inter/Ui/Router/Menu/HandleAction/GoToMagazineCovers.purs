module Inter.Ui.Router.Menu.HandleAction.GoToMagazineCovers where

import Proem

import Core.Mod.Time.Year (Year)
import Data.Lens ((.~))
import Halogen (modify_, raise)

import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.State.State (_magazine)
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine
import Inter.Ui.Router.Menu.Type.State.Magazine (_page)
import Inter.Ui.Router.Menu.Type.Output as MenuOutput
import Inter.Ui.Router.Menu.HandleAction.Util.Scroll (scrollTopMenu)

goToMagazineCovers :: Year -> MenuM Ɩ
goToMagazineCovers year = do
  modify_ (_magazine ◁ _page .~ Magazine.Covers { year })
  raise MenuOutput.MagazineIssueClosed
  scrollTopMenu
