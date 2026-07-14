module Inter.Ui.Mod.ArticleCard.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Mod.ArticleCard.Type (Action(..), ArticleCardM)
import Halogen as Halogen
import Inter.Ui.Mod.ArticleCard.HandleAction.Initialize (initialize)
import Inter.Ui.Mod.ArticleCard.HandleAction.Receive (receive)
import Inter.Ui.Mod.ArticleCard.HandleAction.HandleLinkOutput.Index (handleLinkOutput)

handleAction :: Action -> ArticleCardM Ɩ
handleAction = case _ of
  Initialize -> do
    st <- Halogen.gets identity
    initialize st.input
  Receive input -> receive input
  HandleLinkOutput output -> handleLinkOutput output
