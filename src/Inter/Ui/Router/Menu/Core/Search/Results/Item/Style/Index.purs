module Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Style.Style as Item
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Thumb.Style as Thumb
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Index as Core

staticStyle :: CSS.CSS
staticStyle = do
  Thumb.staticStyle
  Core.staticStyle
  Item.staticStyle
