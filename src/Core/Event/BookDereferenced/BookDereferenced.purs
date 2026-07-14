module Core.Event.BookDereferenced.BookDereferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.BookDereferenced.Payload (Payload)

data BookDereferenced

instance IsEvent BookDereferenced Payload

instance Reflect BookDereferenced where
  reflectName = "BookDereferenced"
