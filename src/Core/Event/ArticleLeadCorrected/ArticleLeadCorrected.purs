module Core.Event.ArticleLeadCorrected.ArticleLeadCorrected where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.ArticleLeadCorrected.Payload (Payload)

data ArticleLeadCorrected

instance IsEvent ArticleLeadCorrected Payload

instance Reflect ArticleLeadCorrected where
  reflectName = "ArticleLeadCorrected"
