module Inter.Ui.Router.Menu.HandleQuery
  ( handleQuery
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Inter.Ui.Router.Menu.Type.State.Magazine (_page)
import Inter.Ui.Router.Menu.Type.State.State (_magazine, _search)
import Halogen (tell, modify_, gets)
import Inter.Ui.Mod.Input.Type.Query as InputQuery
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.Type.Query (Query(..))
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))
import Inter.Ui.Router.Menu.HandleAction.Open (open)
import Inter.Ui.Router.Menu.HandleAction.OpenSearch (openSearch)
import Inter.Ui.Router.Menu.HandleAction.GoToMagazineArticles (goToMagazineArticles)

import Inter.Ui.Router.Menu.Type.State.Search (_authorFilter, _results)
import Network.RemoteData (RemoteData(..))
import Data.Lens ((.~))
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine


handleQuery :: ∀ a. Query a -> MenuM (Maybe a)
handleQuery = case _ of
  FocusSearchInput next -> do
    tell (π @"searchInput") ι (InputQuery.Focus)
    η (Just next)

  OpenSearch mQuery mAuthorFilter next -> do
    -- Open the menu manually.
    open External

    -- If author filter is present, fetch it and set it
    case mAuthorFilter of
      Just { id: authorId, name, ofBook } -> do
        searchState <- gets _.search
        case searchState.authorFilter of
          Just filterState | filterState.id == authorId && filterState.ofBook == ofBook -> ηι
          _ -> do
            modify_ (_search ◁ _results .~ NotAsked)
            modify_ (_search ◁ _authorFilter .~ Just { id: authorId, name, ofBook })
      Nothing -> do
        searchState <- gets _.search
        case searchState.authorFilter of
          Just _ -> do
            modify_ (_search ◁ _results .~ NotAsked)
            modify_ (_search ◁ _authorFilter .~ Nothing)
          Nothing -> ηι

    -- Then open search 
    openSearch External mQuery

    η (Just next)

  OpenMagazineIssue param next -> do
    case param of
      Just slug -> goToMagazineArticles External Nothing slug
      Nothing -> modify_ (_magazine ◁ _page .~ Magazine.Years)
    η (Just next)
