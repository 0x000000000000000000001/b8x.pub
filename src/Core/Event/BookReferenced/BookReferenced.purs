module Core.Event.BookReferenced.BookReferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.BookReferenced.Payload (Payload)

data BookReferenced

instance IsEvent BookReferenced Payload

instance Reflect BookReferenced where
  reflectName = "BookReferenced"
