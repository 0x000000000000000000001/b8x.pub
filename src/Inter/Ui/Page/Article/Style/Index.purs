module Inter.Ui.Page.Article.Style.Index
  (staticStyle
  ) where

import Proem

import CSS as CSS
import Inter.Ui.Page.Article.Style.Style as Style
import Inter.Ui.Page.Article.Content.Style.Index as Content
import Inter.Ui.Page.Article.Hero.Style.Index as Hero
import Inter.Ui.Page.Article.NotFound.Style.Index as NotFound
import Inter.Ui.Page.Article.Error.Style.Index as Error
import Inter.Ui.Page.Article.Books.Style.Index as Books
import Inter.Ui.Page.Article.Related.Style.Index as Related
import Inter.Ui.Page.Article.SocialShare.Style.Index as SocialShare

staticStyle :: CSS.CSS
staticStyle = do
  Style.staticStyle
  Content.staticStyle
  Hero.staticStyle
  NotFound.staticStyle
  Error.staticStyle
  Books.staticStyle
  Related.staticStyle
  SocialShare.style
