module Inter.Ui.Mod.Link.HandleAction.Navigate (navigate) where

import Proem

import Inter.Ui.Capability.Navigate.Navigate (Route)
import Inter.Ui.Capability.Navigate.Trans (navigate) as Trans
import Inter.Ui.Mod.Link.Type (LinkM)

navigate :: Route -> LinkM Ɩ
navigate route = Trans.navigate route
