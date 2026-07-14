module Inter.Ui.Mod.PrettyErrorImage.HandleAction.HandleError (handleError) where

import Proem

import Inter.Ui.Mod.PrettyErrorImage.Type (PrettyErrorImageM, Try(..))
import Halogen (modify_)

handleError :: PrettyErrorImageM Ɩ
handleError = modify_ $ \s -> case s of
  { try: FirstTry _ } ->
    s
      { try =
          s.input.sources.fallback
            ?? FallbackTry
            ⇔ StopTrying
      }

  { try: FallbackTry _ } ->
    s { try = StopTrying }

  _ -> s
