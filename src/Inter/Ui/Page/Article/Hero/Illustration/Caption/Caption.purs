module Inter.Ui.Page.Article.Hero.Illustration.Caption.Caption where

import Data.Maybe (Maybe(..))
import Halogen.HTML (HTML, text)
import Util.Html.Clean.Render.Render (SanitizedHtmlString, render)
import Inter.Ui.Type.InstanceId (InstanceId)
import Inter.Ui.Page.Article.Hero.Illustration.Caption.Style as Style

caption :: ∀ w i r. { id :: InstanceId | r } -> Maybe SanitizedHtmlString -> HTML w i
caption state capMb = case capMb of
  Just cap -> Style.caption_ state.id [ render cap ]
  Nothing -> text ""
