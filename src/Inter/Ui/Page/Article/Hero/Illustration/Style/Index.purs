module Inter.Ui.Page.Article.Hero.Illustration.Style.Index
  (staticStyle
  ) where

import Proem

import CSS as CSS
import Inter.Ui.Page.Article.Hero.Illustration.Style.Style as Style
import Inter.Ui.Page.Article.Hero.Illustration.Caption.Style as Caption
import Inter.Ui.Page.Article.Hero.Illustration.Image.Style as Image

staticStyle :: CSS.CSS
staticStyle = do
  Style.staticStyle
  Caption.staticStyle
  Image.staticStyle
