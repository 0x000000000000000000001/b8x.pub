module Inter.Ui.Page.Article.Content.Style.Index
  (staticStyle
  ) where

import Proem

import CSS as CSS
import Inter.Ui.Page.Article.Content.Style.Style as Style
import Inter.Ui.Page.Article.Content.Body.Style as Body
import Inter.Ui.Page.Article.Content.Notes.Style as Notes

staticStyle :: CSS.CSS
staticStyle = do
  Style.staticStyle
  Body.staticStyle
  Notes.staticStyle
