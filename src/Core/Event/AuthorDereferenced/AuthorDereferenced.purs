module Core.Event.AuthorDereferenced.AuthorDereferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.AuthorDereferenced.Payload (Payload)

data AuthorDereferenced

instance IsEvent AuthorDereferenced Payload

instance Reflect AuthorDereferenced where
  reflectName = "AuthorDereferenced"
