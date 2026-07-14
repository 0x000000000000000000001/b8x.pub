module Inter.Ui.Mod.Link.HandleAction.Receive (receive) where

import Proem

import Inter.Ui.Mod.Link.Type (Input, LinkM)
import Halogen (modify_)

receive :: Input -> LinkM Ɩ
receive input = modify_ _ { input = input }
