module Core.Event.ArticleTitleCorrected.ArticleTitleCorrected where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.ArticleTitleCorrected.Payload (Payload)

data ArticleTitleCorrected

instance IsEvent ArticleTitleCorrected Payload

instance Reflect ArticleTitleCorrected where
  reflectName = "ArticleTitleCorrected"
