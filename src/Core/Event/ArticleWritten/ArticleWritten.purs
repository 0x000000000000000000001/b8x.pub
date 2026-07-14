module Core.Event.ArticleWritten.ArticleWritten where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.ArticleWritten.Payload (Payload)

data ArticleWritten

instance IsEvent ArticleWritten Payload

instance Reflect ArticleWritten where
  reflectName = "ArticleWritten"
