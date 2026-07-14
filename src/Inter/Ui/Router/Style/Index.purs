module Inter.Ui.Router.Style.Index where

import Proem

import Halogen.HTML (HTML)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Mod.Style.Index as Mod
import Inter.Ui.Page.Style.Index as Page
import Inter.Ui.Router.Core.Style as Core
import Inter.Ui.Router.Footer.Style.Index as Footer
import Inter.Ui.Router.Header.Style.Index as Header
import Inter.Ui.Router.Menu.Style.Index as Menu
import Inter.Ui.Router.PrettyBackground.Style.Index as PrettyBackground
import Inter.Ui.Router.Style.Style as Router
import Inter.Ui.Router.WarningBanner.Style.Index as WarningBanner
import Util.Style.Base (noCss)

staticSheet :: ∀ w i. HTML w i
staticSheet = stylesheet do
  Mod.staticStyle
  Page.staticStyle

  Core.staticStyle
  Footer.staticStyle
  Header.staticStyle
  Menu.staticStyle
  PrettyBackground.staticStyle
  Router.staticStyle
  WarningBanner.staticStyle

sheet :: ∀ w i. HTML w i
sheet = stylesheet do
  noCss
