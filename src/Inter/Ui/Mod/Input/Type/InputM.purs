module Inter.Ui.Mod.Input.Type.InputM where

import Halogen (HalogenM)
import Inter.Ui.UiM (UiM)
import Inter.Ui.Mod.Input.Type.State (State)
import Inter.Ui.Mod.Input.Type.Action (Action)
import Inter.Ui.Mod.Input.Type.Slots (Slots)
import Inter.Ui.Mod.Input.Type.Output (Output)

type InputM = HalogenM State Action Slots Output UiM
