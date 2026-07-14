module Inter.Ui.Router.Render where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Halogen.HTML (slot_)
import Inter.Ui.Router.Core.Core (core)
import Inter.Ui.Router.Footer.Footer (footer)
import Inter.Ui.Router.Header.Header (header)
import Inter.Ui.Router.Menu.Menu (menu)
import Inter.Ui.Router.PrettyBackground.PrettyBackground (prettyBackground)
import Inter.Ui.Router.Style.Index (staticSheet, sheet)
import Inter.Ui.Router.Style.Style (router_)
import Inter.Ui.Router.Type (Action, Slots, State)
import Inter.Ui.Router.WarningBanner.WarningBanner (warningBanner)
import Inter.Ui.Mod.Toast.Component as ToastComponent
import Inter.Ui.Mod.LoginModal.Component as LoginModal
import Inter.Ui.Type.Slot (noSlotAddressIndex)
import Type.Proxy (Proxy(..))
import Inter.Ui.UiM (UiM)

render :: State -> ComponentHTML Action Slots UiM
render s@{ route } =
  router_
    [ staticSheet
    , sheet
    , prettyBackground s
    , menu s
    , warningBanner
    , header s
    , core route
    , footer
    , slot_ (Proxy :: Proxy "toast") unit ToastComponent.component { toastEmitter: s.toastEmitter }
    , slot_ (Proxy @"loginModal") noSlotAddressIndex LoginModal.component {}
    ]
