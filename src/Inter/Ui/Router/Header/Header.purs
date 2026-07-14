module Inter.Ui.Router.Header.Header
  (header
  ) where

import Proem hiding (div)

import Halogen (ComponentHTML)
import Inter.Ui.Router.Header.Logo.Logo (logo)
import Inter.Ui.Router.Header.Style.Style (header_)
import Inter.Ui.Router.Type (Action, Slots, State)
import Inter.Ui.UiM (UiM)

header :: State -> ComponentHTML Action Slots UiM
header _ =
  header_
    [ logo
    ]
