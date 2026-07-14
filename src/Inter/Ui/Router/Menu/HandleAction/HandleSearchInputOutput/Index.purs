module Inter.Ui.Router.Menu.HandleAction.HandleSearchInputOutput.Index (handleSearchInputOutput) where

import Proem

import Inter.Ui.Mod.Input.Type.Output as Input
import Inter.Ui.Router.Menu.Type.MenuM (MenuM)
import Inter.Ui.Router.Menu.HandleAction.HandleSearchInputOutput.ValueChanged (handleSearchInputValueChanged)
import Inter.Ui.Router.Menu.HandleAction.HandleSearchInputOutput.Focused (handleSearchInputFocused)
import Inter.Ui.Router.Menu.HandleAction.HandleSearchInputOutput.Blurred (handleSearchInputBlurred)

handleSearchInputOutput :: Input.Output -> MenuM Ɩ
handleSearchInputOutput = case _ of
  Input.ValueChanged value -> handleSearchInputValueChanged value
  Input.Focused -> handleSearchInputFocused
  Input.Blurred -> handleSearchInputBlurred
