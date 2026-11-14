module Inter.Ui.Page.Legal.Legal where

import Proem hiding (div)


import Halogen (ComponentHTML)
import Halogen.HTML (slot)
import Type.Proxy (Proxy(..))
import Inter.Ui.Router.Type (Action, Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Capability.Navigate.Navigate (Route)

import Inter.Ui.Page.Legal.Component as LegalComponent

legal :: Route -> ComponentHTML Action Slots UiM
legal _ = slot (Proxy :: Proxy "legal") unit LegalComponent.component {} absurd
