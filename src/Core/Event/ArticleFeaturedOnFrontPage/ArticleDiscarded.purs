module Core.Event.ArticleFeaturedOnFrontPage.ArticleDiscarded where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.ArticleFeaturedOnFrontPage.Payload (Payload)

data ArticleFeaturedOnFrontPage

instance IsEvent ArticleFeaturedOnFrontPage Payload

instance Reflect ArticleFeaturedOnFrontPage where
  reflectName = "ArticleFeaturedOnFrontPage"
