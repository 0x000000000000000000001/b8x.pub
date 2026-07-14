module Inter.Ui.Router.Menu.UnfoldIcon.Image.Image where

import Proem

import Halogen.HTML (HTML)
import Halogen.HTML.Properties (src)
import Inter.Ui.Router.Menu.Type.State.State (State)
import Inter.Ui.Router.Menu.UnfoldIcon.Image.Style as Style
import Util.File.Path (selfHostedVersionedImageUrl)

image :: ∀ w i. State -> HTML w i
image state =
  Style.image state
    [ src $ selfHostedVersionedImageUrl "1.0.0" "router/menu/unfold.png"
    ]
