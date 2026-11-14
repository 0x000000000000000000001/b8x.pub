module Inter.Ui.Page.Home.HandleAction.Receive
  (receive
  ) where

import Proem

import Halogen (modify_, gets)
import Inter.Ui.Page.Home.Type (HomeM, Input)
import Inter.Ui.Page.Home.HandleAction.Load (load)

receive :: Input -> HomeM Ɩ
receive input = do
  oldInput <- gets _.input
  oldContext <- gets _.context

  when (oldContext /= input.context) do
    modify_ _ { context = input.context }

  when (oldInput /= input) do
    modify_ _ { input = input }

    when (oldInput.theme /= input.theme) load
