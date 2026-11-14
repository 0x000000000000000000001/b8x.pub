module Core.Event.BookEditorCorrected.BookEditorCorrected where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.BookEditorCorrected.Payload (Payload)

data BookEditorCorrected

instance IsEvent BookEditorCorrected Payload

instance Reflect BookEditorCorrected where
  reflectName = "BookEditorCorrected"
