module Inter.Ui.Mod.Input.Type.Value where

import Prelude (class Eq, class Ord)

data DetectionWay = ByEvent -- | ByValue

derive instance Eq DetectionWay
derive instance Ord DetectionWay

data When = Rightaway | OnceChanged DetectionWay

derive instance Eq When
derive instance Ord When

data ControlledValue a
  = Controlled a
  | Uncontrolled When a

derive instance Eq a => Eq (ControlledValue a)
