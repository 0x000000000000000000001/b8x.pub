module Inter.Ui.Router.Menu.Core.Search.Results.Results where

import Prelude (map)
import Halogen.HTML (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Search.Results.Style.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))

results :: State -> Array (ComponentHTML Action Slots UiM)
results state@{ search: { results: remoteResult } } = [ Style.results_ state (map _.html itemsArray) ]
  where
  itemsArray = case remoteResult of
    Success items -> items
    _ -> []

