module Core.Event.MagazineCustomSectionAdded.MagazineCustomSectionAdded where

import Core.Event.Event (class IsEvent)
import Core.Event.MagazineCustomSectionAdded.Payload (Payload)
import Util.Type.Type (class Reflect)

data MagazineCustomSectionAdded

instance IsEvent MagazineCustomSectionAdded Payload

instance Reflect MagazineCustomSectionAdded where
  reflectName = "MagazineCustomSectionAdded"
