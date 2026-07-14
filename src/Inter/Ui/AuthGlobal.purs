module Inter.Ui.AuthGlobal where

import Proem

import Effect (Effect)

foreign import _exposeAuth :: (String -> Effect Unit) -> (String -> Effect Unit) -> Effect Unit
foreign import isLoggedIn :: Effect Boolean
