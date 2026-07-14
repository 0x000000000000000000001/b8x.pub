module Inter.Ui.Router.Menu.Core.Search.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Menu.Core.Search.Input.Style as Input
import Inter.Ui.Router.Menu.Core.Search.Results.Style.Index as Result
import Inter.Ui.Router.Menu.Core.Search.QuitButton.Style as QuitButton
import Inter.Ui.Router.Menu.Core.Search.AuthorFilter.Style as AuthorFilter

staticStyle :: CSS.CSS
staticStyle = do
  Input.staticStyle
  Result.staticStyle
  QuitButton.staticStyle
  AuthorFilter.staticStyle
