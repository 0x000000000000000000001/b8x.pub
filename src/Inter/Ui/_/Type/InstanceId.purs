module Inter.Ui.Type.InstanceId where

import Proem

import Effect (Effect)
import Util.Type.String.ToString (toString)
import Util.Type.Ulid (generateUlid)

newtype InstanceId = InstanceId String

derive newtype instance Eq InstanceId
derive newtype instance Ord InstanceId
derive newtype instance Show InstanceId

generateInstanceId :: Effect InstanceId
generateInstanceId = do
  ulid <- generateUlid
  η $ InstanceId $ toString ulid
