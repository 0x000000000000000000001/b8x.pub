module Inter.Ui.Page.Donate.Donate where

import Proem hiding (div)


import Halogen (ComponentHTML)
import Halogen.HTML (slot)
import Type.Proxy (Proxy(..))
import Inter.Ui.Router.Type (Action, Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Capability.Navigate.Navigate (Route)

import Inter.Ui.Page.Donate.Component as DonateComponent

donate :: Route -> ComponentHTML Action Slots UiM
donate _ = slot (Proxy :: Proxy "donate") unit DonateComponent.component {} absurd
