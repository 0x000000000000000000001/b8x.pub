module Inter.Ui.Router.HandleAction.NavigateToCurrentRouteWithMenuSearchOpen (navigateToCurrentRouteWithMenuSearchOpen) where

import Proem

import Data.Maybe (Maybe(..))
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Halogen (gets)
import Inter.Ui.Capability.Navigate.Navigate (Route(..))
import Inter.Ui.Capability.Navigate.Trans (navigate)
import Inter.Ui.Router.Type (RouteM)


navigateToCurrentRouteWithMenuSearchOpen :: Maybe String -> Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean } -> RouteM Ɩ
navigateToCurrentRouteWithMenuSearchOpen query authorFilter = do
  let
    openWith = case query of
      Just "" -> Nothing
      other -> other

    updateSearch searchParams = case openWith of
      Nothing -> searchParams { openWith = Nothing, withAuthorFilter = authorFilter }
      Just q -> searchParams { openWith = Just q, withAuthorFilter = authorFilter }

  route <- gets _.route
  case route of
    Just (Home r) -> navigate (Home r { menu { search = updateSearch r.menu.search } })
    Just (Theme slug r) -> navigate (Theme slug r { menu { search = updateSearch r.menu.search } })
    Just (Article slug r) -> navigate (Article slug r { menu { search = updateSearch r.menu.search } })
    Just (Donate r) -> navigate (Donate r { menu { search = updateSearch r.menu.search } })
    Just NotFound -> ηι
    Nothing -> ηι
