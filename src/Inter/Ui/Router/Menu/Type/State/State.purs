module Inter.Ui.Router.Menu.Type.State.State where

import Proem

import Data.Lens (Lens')
import Data.Lens.Record (prop)
import Inter.Ui.Router.Menu.Type.State.Search as Search
import Inter.Ui.Router.Menu.Type.State.Newsletter as Newsletter
import Inter.Ui.Router.Menu.Type.State.Magazine as Magazine
import Inter.Ui.Type.ControlledState (ControlledState)
import Inter.Ui.Type.State (WithId)
import Effect.Ref (Ref)
import Data.Maybe (Maybe)
import Inter.Ui.Router.Menu.Type.State.ActivePanel (ActivePanel)
import Inter.Ui.Store.Store as GlobalStore

type State = WithId
  ( open :: ControlledState Boolean
  , activePanel :: ControlledState ActivePanel
  , search :: Search.State
  , newsletter :: Newsletter.State
  , magazine :: Magazine.State
  , isDocMouseMoveThrottled :: Boolean
  , hasMouseEntered :: Maybe (Ref Boolean)
  , me :: Maybe GlobalStore.Me
  )

open' = π :: Π "open"

_open :: ∀ a r. Lens' { open :: a | r } a
_open = prop open'

search' = π :: Π "search"

_search :: ∀ a r. Lens' { search :: a | r } a
_search = prop search'

_hasMouseEntered :: ∀ a r. Lens' { hasMouseEntered :: a | r } a
_hasMouseEntered = prop (π :: Π "hasMouseEntered")

newsletter' = π :: Π "newsletter"

_newsletter :: ∀ a r. Lens' { newsletter :: a | r } a
_newsletter = prop newsletter'

magazine' = π :: Π "magazine"

_magazine :: ∀ a r. Lens' { magazine :: a | r } a
_magazine = prop magazine'

activePanel' = π :: Π "activePanel"

_activePanel :: ∀ a r. Lens' { activePanel :: a | r } a
_activePanel = prop activePanel'

_loginModalOpen :: ∀ a r. Lens' { loginModalOpen :: a | r } a
_loginModalOpen = prop (π :: Π "loginModalOpen")
