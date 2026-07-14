module Inter.Ui.Router.Menu.HandleAction.RemoveAuthorFilter where

import Proem

import Data.Lens ((.~))
import Halogen (modify_, raise)
import Inter.Ui.Router.Menu.HandleAction.FetchResults (fetchResults)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Output (Output(..))
import Inter.Ui.Router.Menu.Type.State.Search (_authorFilter, _results)
import Inter.Ui.Router.Menu.Type.State.State (_search)
import Network.RemoteData (RemoteData(..))
import Data.Maybe (Maybe(..))

handleActionRemoveAuthorFilter :: MenuM Ɩ
handleActionRemoveAuthorFilter = do
  modify_ (_search ◁ _results .~ NotAsked)
  modify_ (_search ◁ _authorFilter .~ Nothing)
  fetchResults
  raise AuthorFilterRemoved
