module Core.Event.ArticleRemovedFromNewsRelatedBlacklist.ArticleRemovedFromNewsRelatedBlacklist where

import Core.Event.Event (class IsEvent)
import Core.Event.ArticleRemovedFromNewsRelatedBlacklist.Payload (Payload)
import Util.Type.Type (class Reflect)

data ArticleRemovedFromNewsRelatedBlacklist

instance IsEvent ArticleRemovedFromNewsRelatedBlacklist Payload

instance Reflect ArticleRemovedFromNewsRelatedBlacklist where
  reflectName = "ArticleRemovedFromNewsRelatedBlacklist"
