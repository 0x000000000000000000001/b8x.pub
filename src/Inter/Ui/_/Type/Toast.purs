module Inter.Ui.Type.Toast where

import Proem

import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)

data ToastType = Success | Error | Info | Warning

derive instance Generic ToastType _
derive instance Eq ToastType
derive instance Ord ToastType
instance Show ToastType where show = genericShow

type Toast =
  { id :: String
  , message :: String
  , tType :: ToastType
  }
