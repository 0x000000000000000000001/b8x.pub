module Inter.Ui.Router.Menu.HandleAction.OpenSearch (openSearch) where

import Proem

import Data.Lens ((.~), (^.))
import Data.Maybe (Maybe(..))
import Effect.Aff (Milliseconds(..), delay)

import Halogen (gets, modify_, raise, tell, fork)
import Inter.Ui.Mod.Input.Type.Query as InputQuery
import Inter.Ui.Router.Menu.HandleAction.FetchResults (fetchResults)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Output (Output(..))
import Inter.Ui.Router.Menu.Type.State.Search (_controlled, _query, _authorFilter)
import Inter.Ui.Router.Menu.Type.State.State (_search, _activePanel)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Type.ControlledState (ControlledState(..), _Controlled, _Uncontrolled, shouldUseControlledPrism)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))

openSearch :: IntentOrigin -> Maybe String -> MenuM Ɩ
openSearch intent mNewQuery = do
  useControlledPrism <- shouldUseControlledPrism intent _activePanel

  modify_ (_activePanel ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ Search)

  case mNewQuery of
    Just newQuery ->
      modify_ (_search ◁ _controlled ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) ◁ _query .~ newQuery)
    _ -> ηι

  controlledState <- gets (_ ^. _search ◁ _controlled)
  authorFilter <- gets (_ ^. _search ◁ _authorFilter)
  let
    query = case controlledState of
      Controlled c -> c.query
      Uncontrolled c -> c.query

  when (intent == Internal) $ raise $ SearchOpened { query, authorFilter: authorFilter <#> \{ id, name, ofBook } -> { id, name, ofBook } }

  -- Wait a tiny bit for the Menu to become visible before focusing the input
  _ <- fork $ do
    ʌ' $ delay (Milliseconds 50.0)
    tell (π @"searchInput") ι InputQuery.Focus

  fetchResults
