module Core.Event.AuthorReferenced.AuthorReferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.AuthorReferenced.Payload (Payload)

data AuthorReferenced

instance IsEvent AuthorReferenced Payload

instance Reflect AuthorReferenced where
  reflectName = "AuthorReferenced"
