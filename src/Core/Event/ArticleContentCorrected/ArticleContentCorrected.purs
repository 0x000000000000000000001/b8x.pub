module Core.Event.ArticleContentCorrected.ArticleContentCorrected where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.ArticleContentCorrected.Payload (Payload)

data ArticleContentCorrected

instance IsEvent ArticleContentCorrected Payload

instance Reflect ArticleContentCorrected where
  reflectName = "ArticleContentCorrected"
