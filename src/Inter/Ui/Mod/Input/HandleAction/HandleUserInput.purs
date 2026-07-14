module Inter.Ui.Mod.Input.HandleAction.HandleUserInput (handleUserInput) where

import Proem

import Data.Lens ((.~))
import Data.Maybe (Maybe(..))
import Data.Traversable (for_)
import Effect.Aff (Milliseconds(..), delay)
import Effect.Ref (read, write)
import Halogen (fork, get, kill, modify_, raise)
import Inter.Ui.Mod.Input.Type.InputM (InputM)
import Inter.Ui.Mod.Input.Type.Output (Output(..))
import Inter.Ui.Mod.Input.Type.State (_value)
import Inter.Ui.Mod.Input.Type.Value (ControlledValue(..), When(..))
import Inter.Ui.Type.ControlledState as ControlledState
import Inter.Ui.Type.ControlledState (shouldUseControlledPrism, _Controlled, _Uncontrolled)
import Inter.Ui.Type.IntentOrigin (IntentOrigin(..))

handleUserInput :: String -> InputM Ɩ
handleUserInput newValue = do
  { input: { value, debounceMs }, debounceFork } <- get

  let
    canBreakOut = case value of
      Uncontrolled (OnceChanged _) _ -> true
      _ -> false

  if canBreakOut then
    modify_ _ { value = ControlledState.Uncontrolled newValue }
  else do
    useControlledPrism <- shouldUseControlledPrism Internal _value
    modify_ (_value ◁ (useControlledPrism ? _Controlled ↔ _Uncontrolled) .~ newValue)

  for_ debounceFork \ref -> do
    maybeForkId <- ʌ $ read ref
    for_ maybeForkId kill

  forkId <- fork do
    ʌ' $ delay $ Milliseconds debounceMs
    raise $ ValueChanged newValue

  for_ debounceFork \ref ->
    ʌ $ write (Just forkId) ref
