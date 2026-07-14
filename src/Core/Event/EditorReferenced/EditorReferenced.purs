module Core.Event.EditorReferenced.EditorReferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.EditorReferenced.Payload (Payload)

data EditorReferenced

instance IsEvent EditorReferenced Payload

instance Reflect EditorReferenced where
  reflectName = "EditorReferenced"
