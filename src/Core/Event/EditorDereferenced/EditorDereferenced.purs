module Core.Event.EditorDereferenced.EditorDereferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.EditorDereferenced.Payload (Payload)

data EditorDereferenced

instance IsEvent EditorDereferenced Payload

instance Reflect EditorDereferenced where
  reflectName = "EditorDereferenced"
