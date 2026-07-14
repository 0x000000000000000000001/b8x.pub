module Core.Event.ArticleAddedToNewsRelatedWhitelist.ArticleAddedToNewsRelatedWhitelist where

import Core.Event.Event (class IsEvent)
import Core.Event.ArticleAddedToNewsRelatedWhitelist.Payload (Payload)
import Util.Type.Type (class Reflect)

data ArticleAddedToNewsRelatedWhitelist

instance IsEvent ArticleAddedToNewsRelatedWhitelist Payload

instance Reflect ArticleAddedToNewsRelatedWhitelist where
  reflectName = "ArticleAddedToNewsRelatedWhitelist"
