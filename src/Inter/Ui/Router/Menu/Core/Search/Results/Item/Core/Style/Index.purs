module Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Style.Style as Core
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Title.Style as Title
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.BooksAndAuthors.Style as BooksAndAuthors
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Section.Style as Section
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.Content.Style as Content
import Inter.Ui.Router.Menu.Core.Search.Results.Item.Core.TextWithMatchingWords.Style.Index as TextWithMatchingWords

staticStyle :: CSS.CSS
staticStyle = do
  Title.staticStyle
  BooksAndAuthors.staticStyle
  Section.staticStyle
  Content.staticStyle
  TextWithMatchingWords.staticStyle
  Core.staticStyle
