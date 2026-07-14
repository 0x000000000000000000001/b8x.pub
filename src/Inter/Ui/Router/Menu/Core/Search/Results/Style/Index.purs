module Inter.Ui.Router.Menu.Core.Search.Results.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Index as Item
import Inter.Ui.Router.Menu.Core.Search.Results.Style.Style as Style

staticStyle :: CSS.CSS
staticStyle = do
  Style.staticStyle
  Item.staticStyle
