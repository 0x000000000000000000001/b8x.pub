module Inter.Ui.Router.Menu.Core.Items.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Items.Style.Style as Items
import Inter.Ui.Router.Menu.Core.Items.Item.Style.Index as Item
import Inter.Ui.Router.Menu.Core.Items.Separator.Style as Separator

staticStyle :: CSS.CSS
staticStyle = do
  Items.staticStyle
  Item.staticStyle
  Separator.staticStyle
