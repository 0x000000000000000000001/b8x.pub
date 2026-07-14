module Core.Event.NewsletterScheduled.NewsletterScheduled where

import Core.Event.Event (class IsEvent)
import Core.Event.NewsletterScheduled.Payload (Payload)
import Util.Type.Type (class Reflect)

data NewsletterScheduled

instance IsEvent NewsletterScheduled Payload

instance Reflect NewsletterScheduled where
  reflectName = "NewsletterScheduled"
