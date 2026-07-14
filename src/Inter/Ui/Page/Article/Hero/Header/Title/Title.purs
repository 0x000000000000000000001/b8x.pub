module Inter.Ui.Page.Article.Hero.Header.Title.Title where

import Halogen.HTML (HTML)
import Util.Html.Clean.Render.Render (SanitizedHtmlString, render)
import Inter.Ui.Page.Article.Hero.Header.Title.Style as Style
import Inter.Ui.Type.InstanceId (InstanceId)

title :: ∀ p i r. { id :: InstanceId | r } -> SanitizedHtmlString -> HTML p i
title state titleTxt = Style.title_ state.id [ render titleTxt ]
