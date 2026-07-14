module Inter.Ui.Router.Menu.HandleAction.Open (open) where

import Proem

import Data.Lens ((.~))
import Data.Maybe (Maybe(..))
import Halogen (get, modify_, raise)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Output (Output(..), WithSearchOpen(..))
import Inter.Ui.Router.Menu.Type.State.State (_open)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Type.ControlledState (ControlledState(..), _Controlled, _Uncontrolled, shouldUseControlledPrism)
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine

open :: IntentOrigin -> MenuM Ɩ
open intent = do
  useControlledPrism <- shouldUseControlledPrism intent _open

  modify_ (_open ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ true)

  { activePanel
  , search:
      { controlled
      , authorFilter
      }
  } <- get

  let
    activePanel' = case activePanel of
      Controlled a -> a
      Uncontrolled a -> a
    withSearchOpen = case activePanel' == Search of
      true ->
        case controlled of
          Controlled c -> YesWithQuery c.query
          Uncontrolled c -> YesWithQuery c.query
      false -> No

  magazineState <- get <#> _.magazine
  let
    magazineIssueOpen = case activePanel' == Magazines of
      true -> case magazineState.page of
        Magazine.Articles p -> Just p.slug
        _ -> Nothing
      false -> Nothing

  when (intent == Internal) $ raise (Opened { search: withSearchOpen, authorFilter: authorFilter <#> \{ id, name, ofBook } -> { id, name, ofBook }, magazineIssueOpen })
