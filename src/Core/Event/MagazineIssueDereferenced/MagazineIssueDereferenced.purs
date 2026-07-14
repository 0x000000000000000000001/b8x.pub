module Core.Event.MagazineIssueDereferenced.MagazineIssueDereferenced where

import Core.Event.Event (class IsEvent)
import Util.Type.Type (class Reflect)
import Core.Event.MagazineIssueDereferenced.Payload (Payload)

data MagazineIssueDereferenced

instance IsEvent MagazineIssueDereferenced Payload

instance Reflect MagazineIssueDereferenced where
  reflectName = "MagazineIssueDereferenced"
