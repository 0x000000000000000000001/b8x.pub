module Inter.Ui.Page.Home.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Page.Home.Type (Action(..), HomeM)
import Inter.Ui.Page.Home.HandleAction.Load (load)
import Inter.Ui.Page.Home.HandleAction.Receive (receive)

handleAction :: Action -> HomeM Ɩ
handleAction = case _ of
  Load -> load
  Receive input -> receive input
  HandleArticleCardOutput _ -> η ι
  HandleNewsletterOutput _ -> η ι
  HandleQuoteLinkOutput _ -> η ι
