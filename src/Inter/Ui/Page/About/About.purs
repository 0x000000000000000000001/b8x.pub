module Inter.Ui.Page.About.About where

import Proem hiding (div)


import Halogen (ComponentHTML)
import Halogen.HTML (slot)
import Type.Proxy (Proxy(..))
import Inter.Ui.Router.Type (Action, Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Capability.Navigate.Navigate (Route)

import Inter.Ui.Page.About.Component as AboutComponent

about :: Route -> ComponentHTML Action Slots UiM
about _ = slot (Proxy :: Proxy "about") unit AboutComponent.component {} absurd
