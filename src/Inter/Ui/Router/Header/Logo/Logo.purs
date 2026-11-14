module Inter.Ui.Router.Header.Logo.Logo where

import Proem hiding (top, div)

import Halogen.HTML (ClassName(..), div, text) as HH
import Halogen.HTML.Properties as HP
import Halogen (ComponentHTML)
import Halogen.HTML.Properties (alt, src)
import Inter.Ui.Router.Header.Logo.Style as Style
import Util.File.Path (selfHostedVersionedImageUrl)
import Inter.Ui.Router.Type (Action(..), Slots)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.Link.Component (link_)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Data.Maybe (Maybe(..))
import CSS (flex)

logo :: ComponentHTML Action Slots UiM
logo =
  link_ @"link"
    { route: Just $ Home { consumeMagicLoginToken: Nothing, menu: { magazineIssueOpen: Nothing, search: { openWith: Nothing, withAuthorFilter: Nothing } } }
    , classes: Just [ Style.containerClass ]
    , display: flex
    , children:
        [ Style.logo
            [ src $ selfHostedVersionedImageUrl "1.0.1" "logo.png"
            , alt "Logo"
            ]
        , HH.div
            [ HP.classes [ HH.ClassName Style.baselineClass ] ]
            [ HH.text "Actualité des livres du monde" ]
        ]
    }
    HandleLinkOutput "logo"
