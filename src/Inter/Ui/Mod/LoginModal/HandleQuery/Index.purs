module Inter.Ui.Mod.LoginModal.HandleQuery.Index (handleQuery) where

import Proem

import Halogen (modify_)
import Inter.Ui.Mod.LoginModal.Type (Query(..), LoginModalM)
import Data.Maybe (Maybe(..))

handleQuery :: ∀ a. Query a -> LoginModalM (Maybe a)
handleQuery = case _ of
  Open a -> do
    modify_ _ { isOpen = true }
    pure (Just a)
  Close a -> do
    modify_ _ { isOpen = false }
    pure (Just a)
