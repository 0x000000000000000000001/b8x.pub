module Inter.Ui.Router.Menu.Type.State.Search where

import Proem

import Core.Mod.Article.Id.Id (ArticleId)
import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Data.Maybe (Maybe)
import Core.Mod.Author.Id.Id (AuthorId)
import Core.Mod.Author.Name.Name as Author
import Halogen.HTML (ComponentHTML)
import Halogen.Query (ForkId)
import Inter.Ui.Router.Menu.Type.Action (Action)
import Inter.Ui.Router.Menu.Type.Slots (Slots)
import Inter.Ui.Type.Remote (Remote)
import Inter.Ui.Type.ControlledState as Base
import Inter.Ui.UiM (UiM)

type ControlledState = Base.ControlledState
  { query :: String
  , withAuthorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }
  }

type SearchItem =
  { html :: ComponentHTML Action Slots UiM
  , id :: Maybe ArticleId
  }

type State =
  { results :: Remote (Array SearchItem)
  , controlled :: ControlledState
  , forkId :: Maybe ForkId
  , authorFilter :: Maybe { id :: AuthorId, name :: Author.Name, ofBook :: Boolean }
  }

controlled' = π :: Π "controlled"

_controlled :: ∀ a r. Lens' { controlled :: a | r } a
_controlled = prop controlled'

results' = π :: Π "results"

_results :: ∀ a r. Lens' { results :: a | r } a
_results = prop results'

forkId' = π :: Π "forkId"

_forkId :: ∀ a r. Lens' { forkId :: a | r } a
_forkId = prop forkId'

query' = π :: Π "query"

_query :: ∀ a r. Lens' { query :: a | r } a
_query = prop query'

authorFilter' = π :: Π "authorFilter"

_authorFilter :: ∀ a r. Lens' { authorFilter :: a | r } a
_authorFilter = prop authorFilter'

withAuthorFilter' = π :: Π "withAuthorFilter"

_withAuthorFilter :: ∀ a r. Lens' { withAuthorFilter :: a | r } a
_withAuthorFilter = prop withAuthorFilter'
