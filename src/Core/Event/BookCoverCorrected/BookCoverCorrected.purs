module Core.Event.BookCoverCorrected.BookCoverCorrected where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.BookCoverCorrected.Payload (Payload)

data BookCoverCorrected

instance IsEvent BookCoverCorrected Payload

instance Reflect BookCoverCorrected where
  reflectName = "BookCoverCorrected"
