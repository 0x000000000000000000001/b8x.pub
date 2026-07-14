module Inter.Ui.Router.Menu.Type.State.ActivePanel where

import Proem

data ActivePanel
  = None
  | Search
  | Newsletters
  | Magazines

derive instance Eq ActivePanel
