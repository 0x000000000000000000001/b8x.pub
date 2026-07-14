module Inter.Ui.Router.Util where

import Proem hiding (div)

import Data.Maybe (Maybe(..))
import Effect.Class (class MonadEffect)
import Inter.Ui.Capability.Navigate.Navigate (Route)
import Inter.Ui.Capability.Navigate.Navigate as Nav
import Util.Storage.Local (getInLocalStorage, setInLocalStorage)

scrollKey :: String
scrollKey = "scroll_01kkw9gdpk86jp293rtzqv8x66"

saveScrollY :: ∀ m. MonadEffect m => Route -> Int -> m Ɩ
saveScrollY route y = setInLocalStorage scrollKey { routePath: Nav.routePath route, y } Nothing

type ScrollValue = { routePath :: String, y :: Int }

recoverScrollY :: ∀ m. MonadEffect m => Route -> m (Maybe Int)
recoverScrollY route = do
  val <- getInLocalStorage @ScrollValue scrollKey

  case val of
    Nothing -> η Nothing
    Just { routePath, y } -> η $ routePath == Nav.routePath route ? Just y ↔ Nothing
