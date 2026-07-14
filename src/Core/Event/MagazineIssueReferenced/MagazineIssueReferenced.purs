module Core.Event.MagazineIssueReferenced.MagazineIssueReferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.MagazineIssueReferenced.Payload (Payload)

data MagazineIssueReferenced

instance IsEvent MagazineIssueReferenced Payload

instance Reflect MagazineIssueReferenced where
  reflectName = "MagazineIssueReferenced"
