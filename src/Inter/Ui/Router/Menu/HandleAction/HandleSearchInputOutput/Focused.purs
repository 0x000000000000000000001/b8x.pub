module Inter.Ui.Router.Menu.HandleAction.HandleSearchInputOutput.Focused (handleSearchInputFocused) where

import Proem

import Data.Maybe (Maybe(..))
import Inter.Ui.Router.Menu.HandleAction.OpenSearch (openSearch)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)

handleSearchInputFocused :: MenuM Ɩ
handleSearchInputFocused = openSearch Internal Nothing
