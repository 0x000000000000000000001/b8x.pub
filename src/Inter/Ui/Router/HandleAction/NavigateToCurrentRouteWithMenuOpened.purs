module Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuOpened (navigateToCurrentRouteWithMenuOpened) where

import Proem

import Data.Maybe (Maybe(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Core.Mod.MagazineIssue.Slug.Slug (Slug)
import Halogen (gets)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Capability.Navigate.Trans (navigate)
import Inter.Ui.Router.Type (RouteM)


navigateToCurrentRouteWithMenuOpened :: Maybe String -> Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean } -> Maybe Slug -> RouteM Ɩ
navigateToCurrentRouteWithMenuOpened query authorFilter magazineIssueOpen = do
  let
    openWith = case query of
      Just "" -> Nothing
      other -> other

    updateSearch searchParams = case openWith of
      Nothing -> searchParams { openWith = Nothing, withAuthorFilter = authorFilter }
      Just q -> searchParams { openWith = Just q, withAuthorFilter = authorFilter }

  route <- gets _.route
  case route of
    Just (Home r) -> navigate (Home r { menu { search = updateSearch r.menu.search, magazineIssueOpen = magazineIssueOpen } })
    Just (Theme slugTheme r) -> navigate (Theme slugTheme r { menu { search = updateSearch r.menu.search, magazineIssueOpen = magazineIssueOpen } })
    Just (Article slugArt r) -> navigate (Article slugArt r { menu { search = updateSearch r.menu.search, magazineIssueOpen = magazineIssueOpen } })
    Just (Donate r) -> navigate (Donate r { menu { search = updateSearch r.menu.search, magazineIssueOpen = magazineIssueOpen } })
    Just NotFound -> ηι
    Nothing -> ηι
