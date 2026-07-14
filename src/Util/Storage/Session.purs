module Util.Storage.Session
  (getInSessionStorage
  , removeInSessionStorage
  , setInSessionStorage
  ) where

import Proem

import Yoga.JSON (class ReadForeign, class WriteForeign)
import Data.Maybe (Maybe)
import Data.Time.Duration (Seconds)
import Effect.Class (class MonadEffect)
import Util.Storage.Storage (getInStorage, setInStorage)
import Web.HTML (window)
import Web.HTML.Window (sessionStorage)
import Web.Storage.Storage (removeItem)

setInSessionStorage :: ∀ m a. MonadEffect m => WriteForeign a => String -> a -> Maybe Seconds -> m Ɩ
setInSessionStorage k v maybeTtl = ʌ do
  storage <- sessionStorage =<< window
  setInStorage storage k v maybeTtl

getInSessionStorage :: ∀ @a m. MonadEffect m => ReadForeign a => String -> m (Maybe a)
getInSessionStorage k = ʌ do
  storage <- sessionStorage =<< window
  getInStorage storage k

removeInSessionStorage :: ∀ m. MonadEffect m => String -> m Ɩ
removeInSessionStorage k = ʌ do
  storage <- sessionStorage =<< window
  removeItem k storage
