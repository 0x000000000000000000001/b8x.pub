module Inter.Ui.Mod.Input.HandleQuery
  ( handleQuery
  ) where

import Proem

import Data.Maybe (Maybe(..))
import Data.Traversable (for_)
import Halogen (getHTMLElementRef)
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.Type.Query (Query(..))
import Inter.Ui.Mod.Input.Util (ref)
import Web.HTML.HTMLElement (focus)

handleQuery :: ∀ a. Query a -> InputM (Maybe a)
handleQuery = case _ of
  Focus next -> do
    maybeEl <- getHTMLElementRef ref
    for_ maybeEl \el -> ʌ $ focus el

    η (Just next)
