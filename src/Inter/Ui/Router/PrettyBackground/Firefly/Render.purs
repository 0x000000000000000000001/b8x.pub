module Inter.Ui.Router.PrettyBackground.Firefly.Render where

import Halogen (ComponentHTML)
import Halogen.HTML.Properties as Ref
import Inter.Ui.Router.PrettyBackground.Firefly.Style.Style (firefly)
import Inter.Ui.Router.PrettyBackground.Firefly.Type (Action, Slots, State)
import Inter.Ui.Router.PrettyBackground.Firefly.Util (ref)
import Inter.Ui.UiM (UiM)

render :: State -> ComponentHTML Action Slots UiM
render _ = firefly [ Ref.ref ref ] []
