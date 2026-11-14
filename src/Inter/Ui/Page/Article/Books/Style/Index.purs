module Inter.Ui.Page.Article.Books.Style.Index
  (staticStyle
  ) where



import Proem

import CSS as CSS
import Inter.Ui.Page.Article.Books.Author.Style as Author
import Inter.Ui.Page.Article.Books.Style as Style

staticStyle :: CSS.CSS
staticStyle = do
  Style.staticStyle
  Author.staticStyle
