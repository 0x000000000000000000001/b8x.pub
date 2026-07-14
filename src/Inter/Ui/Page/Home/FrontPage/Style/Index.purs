module Inter.Ui.Page.Home.FrontPage.Style.Index where

import Proem hiding (div, top)

import CSS as CSS
import Inter.Ui.Page.Home.FrontPage.Column.Style as Column
import Inter.Ui.Page.Home.FrontPage.Style.Style as FrontPage

staticStyle :: CSS.CSS
staticStyle = do
  FrontPage.staticStyle
  Column.staticStyle
