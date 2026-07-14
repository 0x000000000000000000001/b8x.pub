module Inter.Ui.Mod.Newsletter.HandleAction.HandleInput (handleInput) where

import Proem

import Halogen (modify_)
import Inter.Ui.Mod.Input.Type.Output as Input
import Inter.Ui.Mod.Newsletter.Type (NewsletterM, Status(..))

handleInput :: Input.Output -> NewsletterM Ɩ
handleInput = case _ of
  Input.ValueChanged str -> modify_ \state ->
    if state.email == str then state
    else state { email = str, status = Idle }
  _ -> η ι
