module Inter.Ui.Mod.Style.Index where

import Proem (discard)

import CSS as CSS
import Inter.Ui.Mod.ArticleCard.Style as ArticleCard
import Inter.Ui.Mod.Input.Style.Index as Input
import Inter.Ui.Mod.Link.Style as Link
import Inter.Ui.Mod.Loader.Style.Index as Loader
import Inter.Ui.Mod.Modal.Style.Index as Modal
import Inter.Ui.Mod.PrettyErrorImage.Style.Index as PrettyErrorImage
import Inter.Ui.Mod.ArticlesBand.Style as ArticlesBand
import Inter.Ui.Mod.Separator.Style.Index as Separator
import Inter.Ui.Mod.Tooltip.Style.Index as Tooltip
import Inter.Ui.Mod.Button.Style.Index as Button
import Inter.Ui.Mod.Newsletter.Style.Style as Newsletter
import Inter.Ui.Mod.Toast.Style.Style as Toast
import Inter.Ui.Mod.LoadingDots.Style.Index as LoadingDots

staticStyle :: CSS.CSS
staticStyle = do
  ArticleCard.staticStyle
  Input.staticStyle
  Link.staticStyle
  Loader.staticStyle
  Modal.staticStyle
  PrettyErrorImage.staticStyle
  ArticlesBand.staticStyle
  Separator.staticStyle
  Tooltip.staticStyle
  Newsletter.staticStyle
  Toast.staticStyle
  LoadingDots.staticStyle
  Button.sheet
