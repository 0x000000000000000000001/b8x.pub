module Inter.Ui.Type.Output where

import Proem

type NoOutput = Void

noOutputAction :: ∀ a. NoOutput -> a
noOutputAction = absurd
