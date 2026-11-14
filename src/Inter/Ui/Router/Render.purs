module Inter.Ui.Router.Render where

import Proem hiding (div)

import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Halogen.HTML (slot_, slot)
import Inter.Ui.Mod.LoginModal.Component as LoginModal
import Inter.Ui.Mod.StopPub.StopPub as StopPub
import Inter.Ui.Mod.StopPub.Type as StopPubType
import Inter.Ui.Mod.Toast.Component as ToastComponent
import Inter.Ui.Router.Core.Core (core)
import Inter.Ui.Router.Footer.Footer (footer)
import Inter.Ui.Router.Header.Header (header)
import Inter.Ui.Router.Menu.Menu (menu)
import Inter.Ui.Router.PrettyBackground.PrettyBackground (prettyBackground)
import Inter.Ui.Router.Style.Index (staticSheet, sheet)
import Inter.Ui.Router.Style.Style (router_)
import Inter.Ui.Router.Type (Action(..), Slots, State)
import Inter.Ui.Type.Slot (noSlotAddressIndex)
import Inter.Ui.UiM (UiM)
import Type.Proxy (Proxy(..))
import Util.Style.Size as Size

render :: State -> ComponentHTML Action Slots UiM
render s@{ route } =
  router_
    [ staticSheet
    , sheet
    , prettyBackground s
    , menu s
    -- , warningBanner
    , header s
    , core s.context route
    , footer
    , slot_ (Proxy :: Proxy "toast") unit ToastComponent.component { toastEmitter: s.toastEmitter }
    , slot_ (Proxy @"loginModal") noSlotAddressIndex LoginModal.component {}
    , slot (Proxy @"stopPubAym") noSlotAddressIndex StopPub.component { target: Just "#aymStickyFooter", placement: { corner: StopPubType.BottomRight, desktopTranslate: { x: Size.Pct 110.0, y: Size.Pct 0.0 }, mobileTranslate: { x: Size.Pct 110.0, y: Size.Pct 0.0 } }, name: "aymStickyFooter-StopPub" } HandleLinkOutput
    , slot (Proxy @"stopPubMsna") noSlotAddressIndex StopPub.component { target: Just "#msna-ad, .msna-ad", placement: { corner: StopPubType.BottomLeft, desktopTranslate: { x: Size.Pct (-110.0), y: Size.Pct 0.0 }, mobileTranslate: { x: Size.Pct (-110.0), y: Size.Pct 0.0 } }, name: "msna-ad-StopPub" } HandleLinkOutput
    ]
