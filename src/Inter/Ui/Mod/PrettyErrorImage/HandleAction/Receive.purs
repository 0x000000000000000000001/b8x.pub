module Inter.Ui.Mod.PrettyErrorImage.HandleAction.Receive (receive) where

import Proem

import Inter.Ui.Mod.PrettyErrorImage.Type (Input, PrettyErrorImageM, Try(..))
import Halogen (modify_)

receive :: Input -> PrettyErrorImageM Ɩ
receive i = modify_ $ \s ->
  s
    { input = i
    , try =
        s.input.sources /= i.sources
          ? FirstTry i.sources.first
          ↔ s.try
    }
