module Inter.Ui.Page.Article.Hero.Header.Lead.Lead where

import Halogen.HTML (HTML)
import Util.Html.Clean.Render.Render (SanitizedHtmlString, render)
import Inter.Ui.Page.Article.Hero.Header.Lead.Style as Style
import Inter.Ui.Type.InstanceId (InstanceId)

lead :: ∀ p i r. { id :: InstanceId | r } -> SanitizedHtmlString -> HTML p i
lead state leadTxt = Style.lead_ state.id [ render leadTxt ]
