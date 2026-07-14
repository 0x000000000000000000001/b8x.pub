module Util.BroadcastChannel.BroadcastChannel where

import Prelude
import Effect (Effect)

foreign import data BroadcastChannel :: Type

foreign import make :: String -> Effect BroadcastChannel
foreign import postMessage :: BroadcastChannel -> String -> Effect Unit
foreign import onMessage :: BroadcastChannel -> (String -> Effect Unit) -> Effect Unit
