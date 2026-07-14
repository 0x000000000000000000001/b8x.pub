module Inter.Ui.Page.Article.Render
  (render
  ) where



import Data.Maybe (Maybe(..))
import Halogen (ComponentHTML)
import Halogen.HTML (div_, text)
import Inter.Ui.Page.Article.Content.Content (content)
import Inter.Ui.Page.Article.Hero.Hero (hero, heroLoading)
import Inter.Ui.Page.Article.Style.Style as Style
import Inter.Ui.Page.Article.Type (Action, Slots, State)
import Inter.Ui.Page.Article.Related.Related (related)
import Inter.Ui.Page.Article.NotFound.NotFound (notFound)
import Inter.Ui.Page.Article.Error.Error (error_)
import Inter.Ui.Page.Article.Books.Books (books)
import Inter.Ui.UiM (UiM)
import Network.RemoteData (RemoteData(..))

render :: State -> ComponentHTML Action Slots UiM
render state = case state.article of
  Success (Just articleData) ->
    Style.articleContainer_ state.id
      [ hero state articleData
      , content state articleData
      , books state articleData
      , related state
      ]
  Success Nothing -> notFound
  Failure err -> error_ err
  Loading ->
    Style.articleContainer_ state.id
      [ heroLoading state state.cachedInfo ]
  NotAsked -> div_ [ text "" ]
