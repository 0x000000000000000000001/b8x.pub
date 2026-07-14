module Inter.Ui.Router.Menu.Type.Input where

import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel)
import Halogen.Store.Connect (Connected)
import Inter.Ui.Store.Store as GlobalStore
import Inter.Ui.Type.ControlledProp (ControlledProp)
import Data.Maybe (Maybe)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author


import Core.Mod.MagazineIssue.Slug.Slug (Slug)

type Input =
  { open :: ControlledProp Boolean
  , activePanel :: ControlledProp ActivePanel
  , search ::
      ControlledProp
        { query :: String
        , withAuthorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }
        }
  , magazineIssueOpen :: ControlledProp (Maybe Slug)
  }

type InnerInput = Connected (Maybe GlobalStore.Me) Input
