module Inter.Ui.Router.Menu.Core.Search.Results.Results where

import Proem
import Halogen.HTML (ComponentHTML)
import Inter.Ui.Router.Menu.Core.Search.Results.Style.Style as Style
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Halogen (RefLabel(..))
import Halogen.HTML as HH
import Data.Maybe (fromMaybe)

import Data.Array as Array
import Inter.Ui.Router.Menu.Type.State.Search (PaginationState(..))

results :: State -> Array (ComponentHTML Action Slots UiM)
results state@{ search: { results: remoteResult, currentPageIndex, pagination } } = 
  [ Style.results state 
      [ HP.ref (RefLabel "searchResults")
      ] 
      ((map _.html itemsArray) <> paginationButtons)
  ]
  where
  itemsArray = case remoteResult of
    Success pages -> fromMaybe [] (Array.index pages currentPageIndex)
    _ -> []
    
  paginationButtons = case pagination of
    Displaying { hasNextPage } -> 
      let
        isNextAvailable = hasNextPage || case remoteResult of
          Success pages -> currentPageIndex + 1 < Array.length pages
          _ -> false
      in
        [ HH.div 
            [ HP.style "display: flex; justify-content: space-between; align-items: center; padding: 2rem; font-family: 'Inter', sans-serif; font-size: 14px;" ]
            [ HH.a 
                [ HE.onClick \_ -> PreviousSearchPage
                , HP.style $ "cursor: pointer; text-decoration: none; color: #1a1a1a; background-color: white; padding: 0.5rem 1rem; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.1); font-weight: 500;" <> if currentPageIndex > 0 then "" else " opacity: 0.3; pointer-events: none;"
                ] 
                [ HH.text "Précédent" ]
            , HH.span 
                [ HP.style "opacity: 0.5; font-weight: 500;" ] 
                [ HH.text $ "Page " <> show (currentPageIndex + 1) ]
            , HH.a 
                [ HE.onClick \_ -> NextSearchPage
                , HP.style $ "cursor: pointer; text-decoration: none; color: #1a1a1a; background-color: white; padding: 0.5rem 1rem; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.1); font-weight: 500;" <> if isNextAvailable then "" else " opacity: 0.3; pointer-events: none;"
                ] 
                [ HH.text "Suivant" ]
            ]
        ]
    _ -> []

