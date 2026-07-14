module Core.Event.ArticleAddedToNewsRelatedBlacklist.ArticleAddedToNewsRelatedBlacklist where

import Core.Event.Event (class IsEvent)
import Core.Event.ArticleAddedToNewsRelatedBlacklist.Payload (Payload)
import Util.Type.Type (class Reflect)

data ArticleAddedToNewsRelatedBlacklist

instance IsEvent ArticleAddedToNewsRelatedBlacklist Payload

instance Reflect ArticleAddedToNewsRelatedBlacklist where
  reflectName = "ArticleAddedToNewsRelatedBlacklist"
