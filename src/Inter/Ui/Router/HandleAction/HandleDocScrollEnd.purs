module Inter.Ui.Router.HandleAction.HandleDocScrollEnd (handleDocScrollEnd) where

import Proem

import Data.Foldable (for_)
import Effect.Ref (write)
import Halogen (get)
import Inter.Ui.Router.Type (RouteM)
import Inter.Ui.Router.Util (saveScrollY)
import Util.Html.Dom.Dom (getScrollY)
import Data.Maybe (Maybe(..))

handleDocScrollEnd :: RouteM Unit
handleDocScrollEnd = do
  state <- get
  
  for_ state.scrollFork \ref ->
    ʌ $ write Nothing ref

  scrollY <- ʌ getScrollY

  case state.route of
    Just r -> ʌ $ saveScrollY r scrollY
    Nothing -> ηι
