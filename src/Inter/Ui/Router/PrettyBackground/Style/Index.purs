module Inter.Ui.Router.PrettyBackground.Style.Index where

import Proem hiding (top, div)

import CSS as CSS
import Inter.Ui.Router.PrettyBackground.Firefly.Style.Satellite as FireflySatellite
import Inter.Ui.Router.PrettyBackground.Firefly.Style.Style as Firefly
import Inter.Ui.Router.PrettyBackground.Style.Style as PrettyBackground

staticStyle :: CSS.CSS
staticStyle = do
  Firefly.staticStyle
  FireflySatellite.staticStyle
  PrettyBackground.staticStyle
