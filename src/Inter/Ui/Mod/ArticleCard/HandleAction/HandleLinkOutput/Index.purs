module Inter.Ui.Mod.ArticleCard.HandleAction.HandleLinkOutput.Index
  (handleLinkOutput
  ) where

import Proem

import Inter.Ui.Mod.ArticleCard.HandleAction.HandleLinkOutput.Clicked (handleLinkOutputClicked)
import Inter.Ui.Mod.ArticleCard.Type (ArticleCardM)
import Inter.Ui.Mod.Link.Type as Link

handleLinkOutput :: Link.Output -> ArticleCardM Ɩ
handleLinkOutput = case _ of
  Link.Clicked route mouseEvent -> handleLinkOutputClicked route mouseEvent
