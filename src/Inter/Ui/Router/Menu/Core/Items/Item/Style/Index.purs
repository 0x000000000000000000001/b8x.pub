module Inter.Ui.Router.Menu.Core.Items.Item.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Items.Item.Label.Style as Label
import Inter.Ui.Router.Menu.Core.Items.Item.Style.Style as Item

staticStyle :: CSS.CSS
staticStyle = do
  Item.staticStyle
  Label.staticStyle
