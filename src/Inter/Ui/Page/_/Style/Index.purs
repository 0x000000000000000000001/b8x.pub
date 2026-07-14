module Inter.Ui.Page.Style.Index where

import Proem
import CSS as CSS
import Inter.Ui.Page.Home.Style.Index as Home
import Inter.Ui.Page.Article.Style.Index as Article

staticStyle :: CSS.CSS
staticStyle = do
  Home.staticStyle
  Article.staticStyle
