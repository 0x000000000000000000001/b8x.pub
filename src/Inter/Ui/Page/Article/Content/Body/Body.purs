module Inter.Ui.Page.Article.Content.Body.Body
  ( body
  ) where


import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Halogen.HTML (HTML, text)
import Util.Html.Clean.Render.Render (render)
import Inter.Ui.Page.Article.Content.Body.Style as Style


body :: ∀ w i r. { id :: InstanceId | r } -> UiArticle -> HTML w i
body state articleData =
  let
    contentNode = case articleData.content of
      Given c -> render c
      _ -> text ""
  in
    Style.body_ state.id
      [ contentNode ]
