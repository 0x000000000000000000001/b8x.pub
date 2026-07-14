module Inter.Ui.Router.Header.Style.Index where

import Proem

import CSS as CSS
import Inter.Ui.Router.Header.Logo.Style as Logo
import Inter.Ui.Router.Header.Style.Style as Header

staticStyle :: CSS.CSS
staticStyle = do
  Header.staticStyle
  Logo.staticStyle
