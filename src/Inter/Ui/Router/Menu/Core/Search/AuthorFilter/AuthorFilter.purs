module Inter.Ui.Router.Menu.Core.Search.AuthorFilter.AuthorFilter where

import Proem hiding (div)

import Data.Maybe (Maybe(..))
import Util.Type.String.ToString (toString)
import Halogen.HTML (ComponentHTML, div, strong, text)
import Halogen.HTML.Events (onClick)
import Inter.Ui.Mod.Tooltip.Tooltip (tooltip)
import Inter.Ui.Mod.Tooltip.Type (defaultInput)
import Inter.Ui.Router.Menu.Core.Search.AuthorFilter.Style (authorFilterNode)
import Inter.Ui.Router.Menu.Type.Action (Action(..))
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Type.ControlledState (ControlledState(..))
import Inter.Ui.UiM (UiM)
import Util.Style.Anchor (AnchorPosition(..))
import Util.Style.Classname (class_)

authorFilter :: State -> Maybe (ComponentHTML Action Slots UiM)
authorFilter { activePanel, search: { authorFilter: mAuthorFilter } } = do
  let
    activePanel' = case activePanel of
      Controlled a -> a
      Uncontrolled a -> a
    isOpen = activePanel' == Search

  if not isOpen then Nothing
  else do
    filter <- mAuthorFilter
    let name = filter.name
    Just $ authorFilterNode
      []
      [ text $ (if filter.ofBook then "Livre de" else "Article de") <> " :\x00A0"
      , strong [] [ text (toString name) ]
      , tooltip
          { disabled: false
          , inner: div
              [ onClick (κ RemoveAuthorFilter)
              , class_ "closeIcon"
              ]
              [ text "✕" ]
          , outer: text "Ne pas limiter à cet auteur"
          , style: defaultInput.style
              { offset = Just { vertical: 1.0, horizontal: 0.0 }
              , anchorPosition = Just BottomRightToTopRight
              }
          }
      ]
