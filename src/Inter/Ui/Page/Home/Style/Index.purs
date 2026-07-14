module Inter.Ui.Page.Home.Style.Index where

import Proem (discard)

import CSS as CSS
import Inter.Ui.Page.Home.FrontPage.Style.Index as FrontPage
import Inter.Ui.Page.Home.QuoteBlock.Style.Style as QuoteBlock
import Inter.Ui.Page.Home.Style.Style as Home

staticStyle :: CSS.CSS
staticStyle = do
  FrontPage.staticStyle
  Home.staticStyle
  QuoteBlock.staticStyle
