module Inter.Ui.Mod.ArticleCard.HandleAction.HandleLinkOutput.Clicked
  (handleLinkOutputClicked
  ) where

import Proem

import Halogen (raise)

import Inter.Ui.Capability.Navigate.Navigate (Route)
import Inter.Ui.Mod.ArticleCard.Type (ArticleCardM, Output(..))
import Inter.Ui.Mod.Link.Type as Link
import Web.UIEvent.MouseEvent (MouseEvent)


handleLinkOutputClicked :: Route -> MouseEvent -> ArticleCardM Ɩ
handleLinkOutputClicked route mouseEvent = do
  raise $ ClickedLink (Link.Clicked route mouseEvent)
