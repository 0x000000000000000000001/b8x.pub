module Core.Event.AuthorBiographyCorrected.AuthorBiographyCorrected where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.AuthorBiographyCorrected.Payload (Payload)

data AuthorBiographyCorrected

instance IsEvent AuthorBiographyCorrected Payload

instance Reflect AuthorBiographyCorrected where
  reflectName = "AuthorBiographyCorrected"
