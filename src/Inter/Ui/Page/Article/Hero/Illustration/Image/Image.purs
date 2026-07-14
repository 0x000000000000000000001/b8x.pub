module Inter.Ui.Page.Article.Hero.Illustration.Image.Image where

import Halogen.HTML (HTML)
import Halogen.HTML.Properties (src)
import Inter.Ui.Page.Article.Hero.Illustration.Image.Style as Style
import Inter.Ui.Type.InstanceId (InstanceId)

image :: ∀ p i r. { id :: InstanceId | r } -> String -> Boolean -> HTML p i
image state path isPortrait = Style.image state.id isPortrait [ src path ]
