module Inter.Ui.Type.Device where

import Prelude

data Device = Mobile | Tablet | Desktop

derive instance eqDevice :: Eq Device
derive instance ordDevice :: Ord Device

instance Show Device where
  show Mobile = "Mobile"
  show Tablet = "Tablet"
  show Desktop = "Desktop"
