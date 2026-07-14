module Inter.Ui.Router.Menu.HandleAction.HandleSearchInputOutput.ValueChanged (handleSearchInputValueChanged) where

import Proem

import Data.Lens ((.~), (^.))
import Halogen (gets, modify_, raise)
import Inter.Ui.Router.Menu.HandleAction.FetchResults (fetchResults)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Output (Output(..))
import Inter.Ui.Router.Menu.Type.State.Search (_controlled, _query, _authorFilter)
import Inter.Ui.Router.Menu.Type.State.State (_search)
import Inter.Ui.Type.ControlledState (_Uncontrolled)

handleSearchInputValueChanged :: String -> MenuM Ɩ
handleSearchInputValueChanged value = do
  modify_ (_search ◁ _controlled ◁ _Uncontrolled ◁ _query .~ value)

  authorFilter <- gets (_ ^. _search ◁ _authorFilter)
  raise (OpenSearchQueryChanged { query: value, authorFilter: authorFilter <#> \{ id, name, ofBook } -> { id, name, ofBook } })

  fetchResults
