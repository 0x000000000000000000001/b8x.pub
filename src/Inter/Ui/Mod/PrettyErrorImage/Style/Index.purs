module Inter.Ui.Mod.PrettyErrorImage.Style.Index where

import CSS as CSS
import Halogen.HTML (HTML)
import Halogen.HTML.CSS (stylesheet)
import Inter.Ui.Mod.PrettyErrorImage.Image.Style as Image
import Inter.Ui.Mod.PrettyErrorImage.QuestionMark.Style as QuestionMark
import Inter.Ui.Mod.PrettyErrorImage.Style.Style as PrettyErrorImage
import Inter.Ui.Mod.PrettyErrorImage.Type (State)
import Proem (discard)

staticStyle :: CSS.CSS
staticStyle = do
  Image.staticStyle
  QuestionMark.staticStyle
  PrettyErrorImage.staticStyle

sheet :: ∀ w i. State -> HTML w i
sheet s = stylesheet do
  Image.style s
  QuestionMark.style s
  PrettyErrorImage.style s
