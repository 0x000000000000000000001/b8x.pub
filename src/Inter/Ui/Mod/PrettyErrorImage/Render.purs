module Inter.Ui.Mod.PrettyErrorImage.Render
  (render
  ) where

import Proem hiding (div)

import Inter.Ui.Mod.PrettyErrorImage.Image.Image as Image
import Inter.Ui.Mod.PrettyErrorImage.Style.Style (prettyErrorImage_)
import Inter.Ui.Mod.PrettyErrorImage.QuestionMark.QuestionMark as QuestionMark
import Inter.Ui.Mod.PrettyErrorImage.Style.Index (sheet)
import Inter.Ui.Mod.PrettyErrorImage.Type (Action, Slots, State, Try(..))
import Inter.Ui.UiM (UiM)
import Halogen (ComponentHTML)

render :: State -> ComponentHTML Action Slots UiM
render s@{ id, try } =
  prettyErrorImage_ id
    [ sheet s
    , try == StopTrying
        ? QuestionMark.questionMark id
        ↔ Image.image s
    ]