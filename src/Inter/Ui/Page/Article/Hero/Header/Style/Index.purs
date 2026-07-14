module Inter.Ui.Page.Article.Hero.Header.Style.Index
  (staticStyle
  ) where

import Proem

import CSS as CSS
import Inter.Ui.Page.Article.Hero.Header.Style.Style as Style
import Inter.Ui.Page.Article.Hero.Header.Author.Style as Author
import Inter.Ui.Page.Article.Hero.Header.Lead.Style as Lead
import Inter.Ui.Page.Article.Hero.Header.Title.Style as Title

staticStyle :: CSS.CSS
staticStyle = do
  Style.staticStyle
  Author.staticStyle
  Lead.staticStyle
  Title.staticStyle
