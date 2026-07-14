module Core.Event.ArticleDiscarded.ArticleDiscarded where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.ArticleDiscarded.Payload (Payload)

data ArticleDiscarded

instance IsEvent ArticleDiscarded Payload

instance Reflect ArticleDiscarded where
  reflectName = "ArticleDiscarded"
