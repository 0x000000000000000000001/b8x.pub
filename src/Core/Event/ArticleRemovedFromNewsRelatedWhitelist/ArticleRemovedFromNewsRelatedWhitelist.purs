module Core.Event.ArticleRemovedFromNewsRelatedWhitelist.ArticleRemovedFromNewsRelatedWhitelist where

import Core.Event.Event (class IsEvent)
import Core.Event.ArticleRemovedFromNewsRelatedWhitelist.Payload (Payload)
import Util.Type.Type (class Reflect)

data ArticleRemovedFromNewsRelatedWhitelist

instance IsEvent ArticleRemovedFromNewsRelatedWhitelist Payload

instance Reflect ArticleRemovedFromNewsRelatedWhitelist where
  reflectName = "ArticleRemovedFromNewsRelatedWhitelist"
