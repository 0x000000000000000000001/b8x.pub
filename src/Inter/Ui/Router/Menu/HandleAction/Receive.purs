module Inter.Ui.Router.Menu.HandleAction.Receive where

import Proem

import Data.Lens ((.~))
import Data.Maybe (Maybe(..))
import Halogen (get, gets, modify_)
import Inter.Ui.Router.Menu.HandleAction.Close (close)
import Inter.Ui.Router.Menu.HandleAction.CloseActivePanel (closeActivePanel)
import Inter.Ui.Router.Menu.HandleAction.Open (open)
import Inter.Ui.Router.Menu.HandleAction.OpenSearch (openSearch)
import Inter.Ui.Router.Menu.Type.Input (InnerInput)
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.Type.State.Search (_controlled, _authorFilter, _results)
import Network.RemoteData (RemoteData(..))
import Inter.Ui.Router.Menu.Type.State.State (_open, _search, _activePanel)
import Inter.Ui.Type.ControlledProp as ControlledProp
import Inter.Ui.Type.ControlledState as ControlledState
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel(..))
import Inter.Ui.Router.Menu.HandleAction.OpenMagazine (openMagazine)
import Inter.Ui.Router.Menu.HandleAction.OpenNewsletter (openNewsletter)

import Inter.Ui.Router.Menu.HandleAction.GoToMagazineArticles (goToMagazineArticles)
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine

receive :: InnerInput -> MenuM Ɩ
receive input = do
  modify_ \st -> st { me = input.context }
  let { open: open', activePanel: activePanel', search: search', magazineIssueOpen: magazineIssueOpen' } = input.input

  { open: open_
  , activePanel: activePanel_
  , search:
      { controlled: controlled_
      }
  , magazine:
      { page: page_
      }
  } <- get

  case open_ of
    ControlledState.Controlled _ -> do
      newOpen <- do
        case open' of
          ControlledProp.Controlled o -> η o
          ControlledProp.Uncontrolled o -> do
            modify_ (_open .~ ControlledState.Uncontrolled o) -- Becomes uncontrolled.
            η o

      case newOpen of
        true -> open External
        false -> close External

    _ -> ηι

  case activePanel_ of
    ControlledState.Controlled _ -> do
      newActivePanel <- case activePanel' of
        ControlledProp.Controlled a -> η a
        ControlledProp.Uncontrolled a -> do
          modify_ (_activePanel .~ ControlledState.Uncontrolled a) -- Becomes uncontrolled.
          η a

      case newActivePanel of
        Search -> do
          newSearchQuery <- case search' of
            ControlledProp.Controlled c -> η $ Just c.query
            ControlledProp.Uncontrolled c -> η $ Just c.query
          openSearch External newSearchQuery
        Newsletters -> openNewsletter External
        Magazines -> do
          case magazineIssueOpen' of
            ControlledProp.Controlled (Just slug) -> do
              case page_ of
                Magazine.Articles p | p.slug == slug -> ηι
                _ -> goToMagazineArticles External Nothing slug
            ControlledProp.Uncontrolled (Just slug) -> do
              case page_ of
                Magazine.Articles p | p.slug == slug -> ηι
                _ -> goToMagazineArticles External Nothing slug
            _ -> do
              case page_ of
                Magazine.Years -> ηι
                _ -> openMagazine External
        None -> closeActivePanel External

    _ -> ηι

  case controlled_ of
    ControlledState.Controlled _ -> do
      newAuthorFilter <- do
        case search' of
          ControlledProp.Controlled c -> do
            η c.withAuthorFilter
          ControlledProp.Uncontrolled c -> do
            modify_ (_search ◁ _controlled .~ ControlledState.Uncontrolled { query: c.query, withAuthorFilter: c.withAuthorFilter }) -- Becomes uncontrolled.
            η c.withAuthorFilter

      searchState <- gets _.search
      case newAuthorFilter of
        Just { id: authorId, name, ofBook } ->
          case searchState.authorFilter of
            Just filterState | filterState.id == authorId && filterState.ofBook == ofBook -> ηι
            _ -> do
              modify_ (_search ◁ _results .~ NotAsked)
              modify_ (_search ◁ _authorFilter .~ Just { id: authorId, name, ofBook })
        Nothing ->
          case searchState.authorFilter of
            Just _ -> do
              modify_ (_search ◁ _results .~ NotAsked)
              modify_ (_search ◁ _authorFilter .~ Nothing)
            Nothing -> ηι

    _ -> ηι
