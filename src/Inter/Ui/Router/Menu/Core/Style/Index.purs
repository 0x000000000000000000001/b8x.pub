module Inter.Ui.Router.Menu.Core.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Search.Style.Index as Search
import Inter.Ui.Router.Menu.Core.TopSpacer.Style as TopSpacer
import Inter.Ui.Router.Menu.Core.BottomSpacer.Style as BottomSpacer
import Inter.Ui.Router.Menu.Core.Items.Style.Index as Items
import Inter.Ui.Router.Menu.Core.Style.Style as Core
import Inter.Ui.Router.Menu.Core.Newsletter.Style.Style as Newsletter
import Inter.Ui.Router.Menu.Core.Magazine.Style.Style as Magazine

staticStyle :: CSS.CSS
staticStyle = do
  Core.staticStyle
  Search.staticStyle
  TopSpacer.staticStyle
  BottomSpacer.staticStyle
  Items.staticStyle
  Newsletter.staticStyle
  Magazine.staticStyle
