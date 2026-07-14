module Inter.Ui.Mod.Link.Render
  (render
  ) where

import Proem hiding (div)

import Inter.Ui.Mod.Link.Style (link, sheet)
import Inter.Ui.Mod.Link.Type (Action(..), Slots, State)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Capability.Navigate.Navigate (routeCodec)
import Halogen (ComponentHTML)
import Halogen.HTML.Events (onClick)
import Halogen.HTML.Properties (href)
import Routing.Duplex (print)

render :: State -> ComponentHTML Action Slots UiM
render s@{ id, input: { route, classes: classes', children } } =
  link id (classes' ??⇒ [])
    (route
        ??
          (\r ->
              [ href $ print routeCodec r
              , onClick $ HandleClick r
              ]
          )
        ⇔ []
    )
    ([ sheet s ]
        <> children
    )