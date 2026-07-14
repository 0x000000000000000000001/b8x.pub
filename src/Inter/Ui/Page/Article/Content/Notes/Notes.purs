module Inter.Ui.Page.Article.Content.Notes.Notes
  ( notes
  , sources
  ) where

import Core.Message.Query.Result (Return(..))
import Inter.Ui.Type.Model (UiArticle)
import Inter.Ui.Type.InstanceId (InstanceId)
import Data.Maybe (Maybe(..))
import Halogen.HTML (HTML, text)
import Util.Html.Clean.Render.Render (render)
import Inter.Ui.Page.Article.Content.Notes.Style as Style


notes :: ∀ w i r. { id :: InstanceId | r } -> UiArticle -> HTML w i
notes state articleData = case articleData.notes of
  Given (Just n) ->
    Style.notes_ state.id
      [ Style.title_ [ text "Notes" ]
      , render n
      ]
  _ -> text ""

sources :: ∀ w i r. { id :: InstanceId | r } -> UiArticle -> HTML w i
sources state articleData = case articleData.sources of
  Given (Just s) ->
    Style.notes_ state.id
      [ Style.title_ [ text "Sources / Pour aller plus loin" ]
      , render s
      ]
  _ -> text ""
