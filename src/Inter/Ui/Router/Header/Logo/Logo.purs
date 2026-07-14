module Inter.Ui.Router.Header.Logo.Logo where

import Proem hiding (top, div)

import Halogen (ComponentHTML)
import Halogen.HTML.Properties (alt, src)
import Inter.Ui.Router.Header.Logo.Style as Style
import Util.File.Path (selfHostedVersionedImageUrl)
import Inter.Ui.Router.Type (Action(..), Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.Link.Component (link)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Data.Maybe (Maybe(..))
import CSS (inlineBlock)

logo :: ComponentHTML Action Slots UiM
logo =
  link
    { route: Just $ Home { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
    , classes: Nothing
    , display: inlineBlock
    , children:
        [ Style.logo
            [ src $ selfHostedVersionedImageUrl "1.0.0" "logo.png"
            , alt "Logo"
            ]
        ]
    }
    HandleLinkOutput
