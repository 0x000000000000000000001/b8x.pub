module Inter.Ui.Router.PrettyBackground.Firefly.HandleAction.Index
  (handleAction
  ) where

import Proem

import Inter.Ui.Router.PrettyBackground.Firefly.Type (Action(..), FireflyM)
import Inter.Ui.Router.PrettyBackground.Firefly.HandleAction.Initialize (initialize)
import Inter.Ui.Router.PrettyBackground.Firefly.HandleAction.Finalize (finalize)

handleAction :: Action -> FireflyM Ɩ
handleAction = case _ of
  Initialize -> initialize
  Finalize -> finalize
