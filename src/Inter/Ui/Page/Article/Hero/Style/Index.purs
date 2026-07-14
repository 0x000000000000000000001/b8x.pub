module Inter.Ui.Page.Article.Hero.Style.Index
  (staticStyle
  ) where

import Proem

import CSS as CSS
import Inter.Ui.Page.Article.Hero.Style.Style as Style
import Inter.Ui.Page.Article.Hero.Illustration.Style.Index as Illustration
import Inter.Ui.Page.Article.Hero.Header.Style.Index as Header

staticStyle :: CSS.CSS
staticStyle = do
  Style.staticStyle
  Header.staticStyle
  Illustration.staticStyle
