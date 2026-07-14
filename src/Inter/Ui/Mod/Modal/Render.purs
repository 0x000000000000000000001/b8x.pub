module Inter.Ui.Mod.Modal.Render
  (render
  ) where

import Proem hiding (div)

import Inter.Ui.Mod.Modal.Core.Core as Core
import Inter.Ui.Mod.Modal.Style.Style (modal)
import Inter.Ui.Mod.Modal.Style.Index (sheet)
import Inter.Ui.Mod.Modal.Type (Action(..), Slots, State)
import Inter.Ui.Type.Html (noHtml)
import Inter.Ui.UiM (UiM)
import Halogen (Component, ComponentHTML)
import Halogen.HTML.Events (onClick)

render
  :: ∀ q i o
   . Component q i o UiM
  -> State i
  -> ComponentHTML (Action i o) (Slots q o) UiM
render innerComponent s@{ id, input: { open } } =
  modal id
    (open ? [ onClick HandleClick ] ↔ [])
    [ sheet s
    , not open
        ? noHtml
        ↔ Core.core s innerComponent
    ]
